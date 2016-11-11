# frozen_string_literal: true
# Overrides: sufia app/jobs/attach_files_to_work_job.rb
# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkJob < ActiveJob::Base
  queue_as :ingest

  # @param [ActiveFedora::Base] the work class
  # @param [Array<UploadedFile>] an array of files to attach
  def perform(work, uploaded_files)
    uploaded_files.each do |uploaded_file|
      file_set = file_set_type(uploaded_file.use_uri)
      user = User.find_by_user_key(work.depositor)
      actor = CurationConcerns::Actors::FileSetActor.new(file_set, user)
      actor.create_metadata(work, visibility: work.visibility) do |file|
        file.permissions_attributes = work.permissions.map(&:to_hash)
      end

      attach_content(actor, uploaded_file.file)
      uploaded_file.update(file_set_uri: file_set.uri)
    end
  end

  private

    # @param [CurationConcerns::Actors::FileSetActor] actor
    # @param [UploadedFileUploader] file
    def attach_content(actor, file)
      case file.file
      when CarrierWave::SanitizedFile
        actor.create_content(file.file.to_file)
      when CarrierWave::Storage::Fog::File
        import_url(actor, file)
      else
        raise ArgumentError, "Unknown type of file #{file.class}"
      end
    end

    # @param [CurationConcerns::Actors::FileSetActor] actor
    # @param [UploadedFileUploader] file
    def import_url(actor, file)
      actor.file_set.update(import_url: file.url)
      log = CurationConcerns::Operation.create!(user: actor.user,
                                                operation_type: "Attach File")
      ImportUrlJob.perform_later(actor.file_set, log)
    end

    def file_set_type(use_uri)
      return FileSet.new if use_uri.nil?
      FileSet.new.tap do |fs|
        fs.type << use_uri
      end
    end
end

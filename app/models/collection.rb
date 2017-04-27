# frozen_string_literal: true
# Generated by curation_concerns:models:install
class Collection < ActiveFedora::Base
  include AcceptsUris
  include ::CurationConcerns::CollectionBehavior
  include CurationConcerns::BasicMetadata
  include Permissions

  self.indexer = CollectionIndexer

  property :publish_channels, predicate: AIC.publishChannel, class_name: "PublishChannel"

  accepts_uris_for :publish_channels
end

// Controls the workflow of the single and batch asset creation forms by enabling
// tabs in the form and displaying information about available mime types for the selected asset type.

export class AssetWorkflow {

  constructor () {
    this.tab = $('ul[role="tablist"] li')[1]
    this.buttonbar = $('div#fileupload')
    this.tabContent = $('div.tab-content')
    this.type = null
    this.aictype_ns = 'http://definitions.artic.edu/ontology/1.0/type/'
  }

  // setup listeners
  initialize () {
    let $this = this

    // Disable the files tab when the page is loaded. It is only present for #new actions
    if ($('select#asset_type_select').length) {
      if ($('select#asset_type_select option:selected').text() === '') {
        $this.disableFilesTab()
      }
    }

    // For the edit page, display the mime types for the selected asset type
    if ( $('#generic_work_asset_type').val() ) {
      $this.type = $('#generic_work_asset_type').val()
      $('.asset').hide()
      $($this.assetTypeSelector).show()
      $this.selectiveShowHideFields()
    }

    $($this.tab).on('click', function(evt) {
      if ($('select#asset_type_select').length) {
        if ($('select#asset_type_select option:selected').text() === '') {
          evt.preventDefault()
          return false
        }
      }
    })

    $('select#asset_type_select').change(function(evt) {
      if (evt.target.selectedIndex > 0) {
        $this.type = $(evt.target.selectedOptions).val()
        $this.enableFilesTab()
        $('#hidden_asset_type').val($this.type)
        $this.selectiveShowHideFields()
      }
      else {
        $this.disableFilesTab()
        $('#hidden_asset_type').val('')
      }
    })

    $($this.tabContent).on('change', 'select.wf-role', function(evt) {
      $this.updateUploadedFile($(this))
    })
  }

  disableFilesTab() {
    $(this.tab).addClass('disabled')
    $(this.buttonbar).hide()
    $('.asset').hide()
  }

  enableFilesTab() {
    $(this.tab).removeClass('disabled')
    $(this.buttonbar).show()
    $('.asset').hide()
    $(this.assetTypeSelector).show()
  }

  selectiveShowHideFields() {
    $('.selective-hide').hide()
    $('.selective-show-' + this.assetTypeClass).show()
  }

  updateUploadedFile(select) {
    $.ajax({
      url: select.data('url'),
      type: 'PUT',
      data: { 'use_uri': select.val() },
      statusCode: {
        202: function() {
          $(select).attr('data-updated', 'true')
        }
      }
    })
  }

  get assetTypeSelector() {
    return '.asset-' + this.assetTypeClass
  }

  get assetTypeClass() {
    return this.type.replace(this.aictype_ns, '').toLowerCase()
  }

}

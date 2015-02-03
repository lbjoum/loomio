angular.module('loomioApp').factory 'AttachmentRecordsInterface', ($upload, BaseRecordsInterface, AttachmentModel) ->
  class AttachmentRecordsInterface extends BaseRecordsInterface
    model:             AttachmentModel

    upload: (file, progress, success, failure) ->
      @getCredentials().then =>
        newAttachment = @recordStore.attachments.initialize @attachmentParams(file)
        $upload.upload(@uploadParameters(file))
               .progress(progress)
               .error(failure)
               .abort(failure)
               .success ->
                  newAttachment.save().then (response) -> success(response.attachments[0])

    getCredentials: ->
      if !@credentials?
        @restfulClient.get('credentials').then (response) => @credentials = response
      else
        $.Deferred().resolve() # resolve an empty promise to return

    attachmentParams: (file) ->
      filename: file.name
      filesize: file.size
      location: @credentials.url + @uploadKey(file)

    uploadParameters: (file) ->
      url:    @credentials.url
      method: 'POST'
      file:   file
      data:
        utf8:           '✓',
        acl:            @credentials.acl,
        policy:         @credentials.policy,
        signature:      @credentials.signature,
        AWSAccessKeyId: @credentials.AWSAccessKeyId,
        key:            @uploadKey(@credentials, file),
        "Content-Type": file.type or 'application/octet-stream'

    uploadKey: (file) ->
      @credentials.key.replace('${filename}', file.name)

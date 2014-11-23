angular.module('loomioApp').factory 'GroupModel', (RecordStoreService) ->
  class GroupModel
    constructor: (data = {}) ->
      @id =                     data.id
      @key =                    data.key
      @name =                   data.name
      @description =            data.description
      @parentId =               data.parent_id
      @createdAt =              data.created_at
      @membersCanEditComments = data.members_can_edit_comments
      @membersCanRaiseMotions = data.members_can_raise_motions
      @membersCanVote =         data.members_can_vote
      @membersCanStartDiscussions = data.members_can_start_discussions
      @discussionPrivacyOptions   = data.discussion_privacy_options
      @isVisibleToParentMembers   = data.is_visible_to_parent_members

    plural: 'groups'

    discussions: ->
      RecordStoreService.get 'discussions', (discussion) =>
        discussion.groupId == @id

    subgroups: ->
      RecordStoreService.get 'groups', (group) =>
        group.parentId == @id

    memberships: ->
      RecordStoreService.get 'memberships', (membership) =>
        membership.groupId == @id

    members: ->
      RecordStoreService.get('users', _.map(@memberships(), (membership) -> membership.userId))

    admins: ->
      RecordStoreService.get('users', _.map(@memberships(), (membership) -> membership.userId if membership.admin))

    fullName: (separator = '>') ->
      if @parentId?
        "#{@parent().name} #{separator} #{@name}"
      else
        @name

    parent: ->
      RecordStoreService.get('groups', @parentId)
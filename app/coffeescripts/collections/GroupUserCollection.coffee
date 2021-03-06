define [
  'i18n!GroupUserCollection'
  'jquery'
  'compiled/collections/PaginatedCollection'
  'compiled/models/GroupUser'
  'str/htmlEscape'
], (I18n, $, PaginatedCollection, GroupUser, h) ->

  class GroupUserCollection extends PaginatedCollection

    comparator: (user) -> user.get('sortable_name').toLowerCase()

    @optionProperty 'group'
    @optionProperty 'category'

    url: ->
      @url = "/api/v1/groups/#{@group.id}/users?per_page=50"

    initialize: (models) ->
      super
      @loaded = @loadedAll = models?
      @on 'change:groupId', @onChangeGroupId
      @model = GroupUser.extend defaults: {groupId: @group.id, @category}

    load: (target = 'all') ->
      @loadAll = target is 'all'
      @loaded = true
      @fetch() if target isnt 'none'
      @load = ->

    onChangeGroupId: (model, groupId) =>
      @removeUser model
      @groupUsersFor(groupId)?.addUser model

    membershipsLocked: ->
      false

    addUser: (user) ->
      if @membershipsLocked()
        @get(user)?.moved()
        return

      if @loaded
        if @get(user)
          @flashAlreadyInGroupError user
        else
          @add user
          @increment 1
        user.moved()
      else
        user.once 'ajaxJoinGroupSuccess', (data) =>
          return if data.just_created
          # uh oh, we already had this user -- undo the increment and flash an error.
          @increment -1
          @flashAlreadyInGroupError user
        @increment 1

    flashAlreadyInGroupError: (user) ->
      $.flashError I18n.t 'flash.userAlreadyInGroup',
        "WARNING: %{user} is already a member of %{group}",
        user: h(user.get('name'))
        group: h(@group.get('name'))

    removeUser: (user) ->
      return if @membershipsLocked()
      @increment -1
      @remove user if @loaded

    increment: (amount) ->
      @group.increment 'members_count', amount

    groupUsersFor: (id) ->
      @category?.groupUsersFor(id)


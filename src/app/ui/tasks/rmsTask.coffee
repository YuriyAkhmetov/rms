module.exports = (ngModule = angular.module 'ui/tasks/rmsTask', []).name

ngModule.run ['$rootScope', (($rootScope) ->
  $rootScope.modal = {type: null}
  return)]

# Zork: This functionality slows down digest cycle, since <element>.width() and .positions() takes to long.  Would be nice to figure out another way of adding 'up' class to duedate

#ngModule.directive 'rmsTaskDuration', ['$rootScope', '$timeout', (($rootScope, $timeout) ->
#    restrict: 'A'
#    require: '^rmsTask'
#    link: (($scope, element, attrs, rmsTask) ->
#      if attrs.rmsTaskDuration.length > 0
#        return unless $scope.$eval attrs.rmsTaskDuration
#      rmsTask.setDuration element
#      $scope.$on '$destroy', (->
#        rmsTask.setDuration null
#        return)
#      return))]
#
#ngModule.directive 'rmsTaskDueDate', ['$rootScope', '$timeout', (($rootScope, $timeout) ->
#    restrict: 'A'
#    require: '^rmsTask'
#    link: (($scope, element, attrs, rmsTask) ->
#      rmsTask.setDuedate element
#      $scope.$on '$destroy', (->
#        rmsTask.setDuedate null
#        return)
#      return))]

ngModule.directive 'rmsTask', ['$rootScope', '$timeout', (($rootScope, $timeout) ->
    restrict: 'A'
    require: 'ngModel'
#    controller: ['$scope', (($scope) ->
#      @unwatch = null
#      fix = (=>
#        if (duration = @duration) && (duedate = @duedate)
#          if !@unwatch
#            @unwatch = $scope.$watch (-> return (duration.position().left + duration.width()) >= duedate.position().left),
#              ((overlap) ->
#                console.info 'overlap'
#                $scope.overlap = overlap
#                duedate.toggleClass 'up', overlap
#                return)
#        else if @unwatch
#          @unwatch()
#          @unwatch = null
#        return)
#      @setDuration = ((durationElement) =>
#        $scope.duration = @duration = durationElement
#        fix()
#        return)
#      @setDuedate = ((duedateElement) =>
#        $scope.duedate = @duedate = duedateElement
#        fix()
#        return)
#      return)]
    link: (($scope, element, attrs, model) ->
      element.on 'click', ((e)->
        e.stopPropagation()
        if (modal = $rootScope.modal).type != 'task-edit'
          $rootScope.modal =
            type: 'task-edit'
            task: model.$viewValue
            pos: element.offset()
          $rootScope.$digest()
        else if modal.task != model.$viewValue
          $rootScope.modal = {type: null}
          $rootScope.$digest()
          $rootScope.$evalAsync (->
            $rootScope.modal =
              type: 'task-edit'
              task: model.$viewValue
              pos: element.offset()
            return), 0
        return)

      element.on 'mouseover', ((e)->
        e.stopPropagation()
        if 0 <= ['task-info', null].indexOf($rootScope.modal.type)
          $rootScope.modal =
            type: 'task-info'
            task:  model.$viewValue
            pos: element.offset()
          $rootScope.$digest()
        return)

      element.on 'mouseleave', ((e)->
        e.stopPropagation()
        if 0 <= ['task-info'].indexOf($rootScope.modal.type)
          $rootScope.modal =
            type: null
          $rootScope.$digest()
        return)

      listenerFunc = undefined

      $scope.$watch "#{attrs.rmsTask}.$u", ((val) ->
        if val
          # The jQuery event object does not have a dataTransfer property
          el = element[0]
          el.draggable = true
          el.addEventListener 'dragstart', listenerFunc = ((e)-> # Note: If we use jQuery.on for this event, we don't have e.dataTransfer option
            $rootScope.modal =
              type: 'drag-start'
              task: $scope.$eval attrs.rmsTask
              scope: $scope
            element.addClass 'drag-start'
            $rootScope.$digest()
            e.dataTransfer.setDragImage($('#task-drag-ghost')[0], 20, 20)
            return)
          element.on 'dragend', ((e)->
            $rootScope.modal = {type: null}
            element.removeClass 'drag-start'
            $rootScope.$digest()
            return)
        else
          el = element[0]
          el.draggable = false
          el.removeEventListener 'dragstart', listenerFunc
          element.off 'dragend'
        return)

      return)
    )]

ngModule.directive 'setTaskVisible', [(() ->
    restrict: 'A'
    link: (($scope, element, attrs) ->
      path = attrs.setTaskVisible
      $scope.$eval "#{path}.setVisible(true)"
      $scope.$on '$destroy', (->
        $scope.$eval "#{path}.setVisible(false)"
        return)
      return)
    )]

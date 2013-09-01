require 'redmine'

require_dependency 'redmine_issues_summary/view_hook_listener'

Redmine::Plugin.register :redmine_issues_summary do
  name 'Redmine Issues Summary plugin'
  author 'Harald Roeck'
  description 'This is a plugin for Redmine that show a summary of the issues at the bottom in the issue list'
  version '0.0.1'
  url 'http://github.com/hroeck/redmine_issues_summary'
end

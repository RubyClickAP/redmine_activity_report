require 'redmine'
require_dependency 'activity_report'
require_dependency 'activity_report/patches/project_patch'
require_dependency 'activity_report/patches/projects_helper_patch'

Redmine::Plugin.register :redmine_activity_report do
  name 'Redmine Activity Report plugin'
  url 'https://github.com/centosadmin/redmine_activity_report'
  description 'This is a plugin for Redmine which generate time reports for projects'
  version '1.1.3'
  author 'Centos-admin.ru'
  author_url 'http://centos-admin.ru'

  settings(partial: 'activity_report/settings',
           default: { 'time_for_reaction' => 15,
                      'alarm_priority_ids' => Issue.ids.last(2).map(&:to_s)})

  project_module :activity_report do
    permission :manage_activity_report_settings, {
      projects: :settings,
      activity_report_settings: :save,
    }
  end
end

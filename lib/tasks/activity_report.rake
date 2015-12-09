def send_activity_reports(period)
  yesterday = 1.day.ago.to_date
  interval = if period == 'daily'
               yesterday
             elsif period == 'weekly'
               (yesterday.beginning_of_week..yesterday.end_of_week).to_a
             elsif period == 'monthly'
               (yesterday.beginning_of_month..yesterday.end_of_month).to_a
             end

  Project.joins(:time_entries).where(time_entries: {spent_on: interval}).uniq.each do |project|
    if project.module_enabled?(:activity_report) and project.active?
      activity_group_ids = project.activity_group_ids
      activity_user_ids = project.activity_user_ids

      group_users = project.groups.where(id: activity_group_ids).map(&:users).flatten
      users = project.users.where(id: activity_user_ids)

      all_activity_user_ids = (group_users + users).uniq.map(&:id)

      report_user_ids = project.report_user_ids
      report_users = project.users.where(id: report_user_ids)

      project_ids = if project.with_subprojects.present?
                      Project.where(project.project_condition(true)).pluck(:id)
                    else
                      [project.id]
                    end

      report_users.each do |user|
        ActivityReportMailer.report(period, user, interval, project_ids, all_activity_user_ids).deliver_now
      end
    end
  end
end

namespace :activity_report do
  task :daily => :environment do
    send_activity_reports('daily')
  end
  task :weekly => :environment do
    send_activity_reports('weekly')
  end
  task :monthly => :environment do
    send_activity_reports('monthly')
  end
end

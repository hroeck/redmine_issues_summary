module IssuesSummary
	class ViewHookListener < Redmine::Hook::ViewListener
		def get_timeunit()
			unit = 'hours'
			if Setting.plugin_redmine_issues_summary['timeunit'] == 'days'
				unit = 'days'
			end
			return unit
		end

		def calculate_times(issues)
			estimated_sum = 0.0
			spent_sum = 0.0
			issues.each do |issue|
				if issue.estimated_hours && issue.leaves.count == 0
					estimated_sum = estimated_sum + issue.estimated_hours 
				end
				spent_sum = spent_sum + issue.spent_hours
			end
			if get_timeunit == 'days'
				estimated_sum = estimated_sum/8
				spent_sum = spent_sum/8
			end
			{:estimated => estimated_sum, :spent => spent_sum}
		end

		# Redmine Hook: context contains issues, project and query
		def view_issues_index_bottom(context={})
			sum = calculate_times(context[:issues])
			html = '<div class="box" id="issue_sum">'
			html += <<EOHTML
			Estimated #{get_timeunit()}:  #{sum[:estimated]} Spent #{get_timeunit()}: #{sum[:spent]} <br/>
			<p> 
EOHTML
			html += '</div><p>'
		end
	end
end

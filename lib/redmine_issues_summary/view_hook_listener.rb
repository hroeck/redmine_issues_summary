module IssuesSummary
	class ViewHookListener < Redmine::Hook::ViewListener
		def calculate_times(issues)
			estimated_sum = 0.0
			spent_sum = 0.0
			issues.each do |issue|
			 if issue.estimated_hours && issue.leaves.count == 0
				estimated_sum = estimated_sum + issue.estimated_hours 
                         end
			  spent_sum = spent_sum + issue.spent_hours
			end
			{:estimated => estimated_sum, :spent => spent_sum}
		end
		def view_issues_index_bottom(context={})
			sum = calculate_times(context[:issues])
			html = '<div class="box" id="issue_sum">'
			html += <<EOHTML
			Estimated hours:  #{sum[:estimated]} Spent hours: #{sum[:spent]} <br/>
			Estimated days:   #{sum[:estimated]/8} Spent days: #{sum[:spent]/8}
			<p> 
EOHTML
			html += '</div><p>'
		end
	end
end

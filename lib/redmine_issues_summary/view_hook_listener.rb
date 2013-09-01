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
			if get_timeunit() == 'days'
				estimated_sum = estimated_sum/8
				spent_sum = spent_sum/8
			end
			{:estimated => estimated_sum, :spent => spent_sum}
		end

		# Redmine Hook: context contains issues, project and query
		def view_issues_index_bottom(context={})
			sum = calculate_times(context[:issues])
			html = <<EOHTML
			<div id="issue_summary" style="visibility: hidden">
			<table class='list issues'>
			<thead>
			<tr><th></th><th>#{get_timeunit() == 'days' ? 'Days' : 'Hours'}</th></tr>
			</thead>
			<tbody>
			<tr> <td> Estimated </td><td> #{sum[:estimated]}</td></tr>
			<tr> <td> Spent </td><td> #{sum[:spent]} </td></tr>
			<tr> <td> Open </td><td> #{sum[:estimated] - sum[:spent]} </td></tr>
			</tbody>
			</table>
			</div>
			<script type="text/javascript">
			buttons = document.getElementsByClassName('buttons hide-when-print')[0];
			buttons.innerHTML = buttons.innerHTML + ' <a class="icon icon-checked" href="#" onclick="show_stats()"> Show Stats </a>'
			top.summary = null;
			function show_stats() {
				if (top.summary == null)
				{
					top.summary = document.getElementById('issue_summary');
				}
				if (top.summary.style.visibility == 'hidden')
				{
					document.getElementsByClassName('buttons hide-when-print')[0].appendChild(top.summary);
					top.summary.style.visibility = 'visible';
				} 
				else
				{
					document.getElementsByClassName('buttons hide-when-print')[0].removeChild(top.summary);
					top.summary.style.visibility = 'hidden';
				}
		    }
			</script>
EOHTML
		end
	end
end

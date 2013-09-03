module IssuesSummary
	class ViewHookListener < Redmine::Hook::ViewListener
		def get_timeunit()
			unit = 'hours'
			if Setting.plugin_redmine_issues_summary['timeunit'] == 'days'
				unit = 'days'
			end
			return unit
		end

		def get_divisor()
			if get_timeunit() == 'days'
				return 8
			end
			return 1
		end

		def get_timeunit_name()
			return get_timeunit() == 'days' ? 'Days' : 'Hours'
		end

		def sort_stats(stats)
			sorted = {}
			stats.keys.sort.each do |k|
				sorted[k] = stats[k]
			end
			return sorted
		end

		def calc_stats(issues)
			stats = Hash.new({:estimates => 0.0, :spent => 0.0, :issues => 0})
			issues.each do |issue|
				version = ' '
				if issue.fixed_version
					version = issue.fixed_version.to_s
				end
				estimate = stats[version][:estimates] 
				if issue.estimated_hours && issue.leaves.count == 0
					estimate = estimate + issue.estimated_hours/get_divisor()
				end
				spent = stats[version][:spent] + issue.spent_hours/get_divisor()
				issues = stats[version][:issues]
				stats[version] = {:estimates => estimate, :spent => spent, :issues => issues + 1}
			end
			return sort_stats(stats)
		end

		def add_sum(stats)
			sums = {:estimates => 0.0, :spent => 0.0, :issues => 0}
			stats.values.each do  |s| 
				sums[:issues] = sums[:issues] + s[:issues] 
				sums[:estimates] = sums[:estimates] + s[:estimates] 
				sums[:spent] = sums[:spent] + s[:spent] 
			end
			stats["Sum"] = sums
		end


		# Redmine Hook: context contains issues, project and query
		def view_issues_index_bottom(context={})
			stats = calc_stats(context[:issues])
			add_sum(stats)
			render_html(stats)
		end

		def render_html(stats)
			html = <<EOHTML
			<fieldset id="issue_summary" class="collapsible collapsed">
			<legend onclick="toggleFieldset(this);">Stats</legend>
			<div style="display: none;">
			<table class='list issues'>
			<thead>
			<tr><th>Version</th>
				<th>Num Issues</th>
				<th>Estimated #{get_timeunit_name()}</th>
				<th>Spent #{get_timeunit_name()}</th>
				<th>Open #{get_timeunit_name()}</th>
			</tr>
			</thead>
			<tbody>
EOHTML
			stats.each do |version, stat|
				html += <<EOHTML
				<tr> 
				<td> #{version} </td>
				<td> #{stat[:issues]} </td>
				<td> #{stat[:estimates].round(3)} </td>
				<td> #{stat[:spent].round(3)}</td>
				<td> #{(stat[:estimates] - stat[:spent]).round(3)}</td>
				</tr>
EOHTML
			end

			html += <<EOHTML
			</tbody>
			</table>
			</div>
			</fieldset>
			<script type="text/javascript">
			document.getElementById("query_form_content").appendChild(document.getElementById('issue_summary'));
			</script>
EOHTML
		end
	end
end

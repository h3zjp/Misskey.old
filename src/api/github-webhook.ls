require! {
	'github-webhook-handler': github-webhook-handler
	'./internal/create-status'
	'../models/user': User
	shelljs
	'../config'
}

module.exports = (app) ->
	app.all '*' (req, res, next) ->
		handler = github-webhook-handler {path: '/github-webhook', secret: config.github-webhook-secret}

		(err, noticer) <- User.find-one {screen-name: 'misskey_github'}

		handler.on \error (err) ->
			console.error 'Error:' err.message

		handler.on \push (event) ->
			switch (event.payload.ref)
			| \refs/heads/master =>
				create-status null noticer, "安定チャンネルにPushされたようです。(master)\n#{event.payload.after}\n**まもなくデプロイされる可能性があります。**" .then!
			| \refs/heads/develop =>
				shelljs.exec '/var/www/misskey/development/deploy' {async: true}
				create-status null noticer, "開発チャンネルにPushされたようです。(develop)\n#{event.payload.after}"
			| _ =>
				create-status null noticer, "Pushされたようです。#{event.payload.ref}" .then!

		handler.on \fork (event) ->
			repo = event.payload.forkee
			text = "Forkされました。\n#{repo.html_url}"
			create-status null noticer, text .then!

		handler.on \pull_request (event) ->
			pr = event.payload.pull_request
			text = switch (event.payload.action)
				| \unassigned => "担当が解除されました:「#{pr.title}」\n#{pr.html_url}"
				| \labeled => "ラベルが付与されました:「#{pr.title}」\n#{pr.html_url}"
				| \unlabeled => "ラベルが削除されました:「#{pr.title}」\n#{pr.html_url}"
				| \opened => "新しいPull Requestが開かれました:「#{pr.title}」\n#{pr.html_url}"
				| \closed =>
					if pr.merged
						"Pull RequestがMergeされました:「#{pr.title}」\n#{pr.html_url}"
					else
						"Pull Requestが閉じられました:「#{pr.title}」\n#{pr.html_url}"
				| \reopened => "Pull Requestが再度開かれました:「#{pr.title}」\n#{pr.html_url}"
			create-status null noticer, text .then!

		handler.on \issues (event) ->
			issue = event.payload.issue
			text = switch (event.payload.action)
				| \unassigned => "担当が解除されました:「#{issue.title}」\n#{issue.html_url}"
				| \labeled => "ラベルが付与されました:「#{issue.title}」\n#{issue.html_url}"
				| \unlabeled => "ラベルが削除されました:「#{issue.title}」\n#{issue.html_url}"
				| \opened => "新しいIssueが開かれました:「#{issue.title}」\n#{issue.html_url}"
				| \closed => "Issueが閉じられました:「#{issue.title}」\n#{issue.html_url}"
				| \reopened => "Issueが再度開かれました:「#{issue.title}」\n#{issue.html_url}"
			create-status null noticer, text .then!

		handler.on \issue_comment (event) ->
			issue = event.payload.issue
			comment = event.payload.comment
			text = switch (event.payload.action)
				| \created => "Issue「#{issue.title}」にコメント:#{comment.user.login}「#{comment.body}」\n#{comment.html_url}"
			create-status null noticer, text .then!

		handler req, res, (err) ->
			next!

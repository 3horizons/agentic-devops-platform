module github.com/${{ values.repoUrl | projectSlug }}

go 1.22

require (
	github.com/go-chi/chi/v5 v5.0.11
	go.uber.org/zap v1.26.0
)

require go.uber.org/multierr v1.11.0 // indirect

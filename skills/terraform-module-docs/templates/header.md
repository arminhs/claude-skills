# <Module title>
<!-- No bare underscores in headings; wrap names in backticks: `my_module` -->

<One paragraph: what the module deploys and for whom. Link to the examples directory, e.g. "Common deployment examples can be found in [examples/](./examples).">

## Usage

<One or two sentences describing what the example below builds and which options it shows.>

```hcl
module "<name>" {
  source  = "<namespace>/<name>/<provider>"
  version = ">= <major>.<minor>.0"

  # Required inputs
  <input> = "<value>"

  # Optional inputs with non-obvious values get an inline comment
  <input> = "<value>" # options: "<a>", "<b>"
}
```

<Optional feature sections, one `##` heading each, every section anchored by an `hcl` snippet.>

<Optional `## Common Errors and their Fixes` section: quote the error with `>`, then bullet the fixes with snippets.>

## Contributing

Please see our [developer documentation](./contributing.md) for guidance on contributing to this module.

# ExAppInfo

Helper to get or set Application properties. Useful for CI processes like Jenkins
or Travis.

## Installation

The package can be installed
by adding `ex_app_info` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ex_app_info, "~> 0.2.0"}]
end
```

## Usage

Get a version:

```
$ mix ex_app_info.version.get
0.2.0
```

Set a version:

```
$ mix ex_app_info.version.set 0.3.0
version updated: 0.2.0 to 0.3.0
```

(more CI helpers to come...)

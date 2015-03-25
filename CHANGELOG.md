CHANGELOG of Itamae::Kitchen

## 0.2.4

- Compati: include chef_helper as string
    - for test-kitchen 1.4.0
    - It is tempolaly imprement.

## 0.2.3

- Bug: Clash on centos6 with Gemfile.
    - set bundle config shebang to chef_omnibus_bin_dir

## 0.2.2

- experimental: append suffix `.rb` for run_list if missing.

## 0.2.1

- Fix: support with_ohai with plugins
    - include `gem 'ohai'` to Gemfile
    - on centos, shoud set ohai version same as omnibus-chef included (native extention building will fail.).

## 0.2.0

- Feature: support attributes.
    - attributes will merge with node_json.

## 0.1.1

- Plugin shoud work under bundler.
    - if exist Gemfile in Kitchen/, itamae run under bundler.

## 0.1.0

- Use run_list instead of recipe_list.
    - the `run_list` will merge both platforms and suites by data_munger.

## 0.0.5

- Cleanup: update itamae_root behavior.
- Cleanup: remove few debug output.

## 0.0.4

- Bugfix: itamae not found on centos6.

## 0.0.3

- use chef-apply for install itamae-plugins(idempotent operation).

## 0.0.2

- cleanup code
- cleanup sandbox
- cleanup remote root_path before converge
- option with_ohai
- option sudo_command
- option itamae_option
- plugin install by embedded gem (every run)

## 0.0.1

- Initial release
- simple comverge

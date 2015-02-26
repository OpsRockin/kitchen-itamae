CHANGELOG of Itamae::Kitchen

## 0.1.1

- Plugin shoud work under bundler.

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

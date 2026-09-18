# Upgrade from version <previous> to version <major>

<One paragraph on why the major version changed and what users must do differently.>

## Preparation for upgrade

1. Create a backup of your `tfstate` file, for example: `terraform state pull | tee tfstate-v<previous>.bak`
1. List the resources that require modification: `terraform state list | grep -e <pattern> | tee resources_to_replace.txt`

## Upgrade procedure

### Overview

1. <First change, for example a renamed variable>
1. <Second change, for example a resource type swap via `terraform state` commands>
1. Verify no unintended changes via `terraform plan`

You can always fall back to the prior state using the backup you created.

### <Resource or variable group>

For each `<old resource type>`, run the following commands, replacing the relevant parts:

```shell
terraform state rm '<old address>'
terraform import '<new address>' <id>
```

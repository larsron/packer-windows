#! /bin/bash
box_path=$1
box_name=$2
description=$3
version=$4
provider=$5
checksum=($(sha1sum $box_path/$box_name.box))
cat > "$box_path/$box_name.metadata.json" <<-EOF
{
  "name": "$box_name",
  "description": "$description",
  "versions": [
    {
      "version": "$version",
      "providers": [
        {
          "name": "$provider",
          "url": "file://$box_path/$box_name.box",
          "checksum_type": "sha1",
          "checksum": "$checksum"
        }
      ]
    }
  ]
}
EOF
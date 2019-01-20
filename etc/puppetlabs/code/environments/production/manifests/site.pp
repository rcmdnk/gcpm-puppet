$main_role = ""
$sub_role = ""

node /^gcp-.*ce*/ {
  $main_role = "ce"
  $sub_role = "gcp"
  lookup('classes', Array[String], 'unique').include
}

node /^gcp-.*wn*/ {
  $main_role = "wn"
  $sub_role = "gcp"
  lookup('classes', Array[String], 'unique').include
}

create_resources('accounts::user', lookup('accounts::user', {merge => hash}))

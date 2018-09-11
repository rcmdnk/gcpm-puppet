$main_role = ""
$sub_role = ""

node /^gcp-ce*/ {
  $main_role = "manager"
  $sub_role = "gcp"
  lookup('classes', Array[String], 'unique').include
}

node /^gcp-wn*/ {
  $main_role = "worker"
  $sub_role = "gcp"
  lookup('classes', Array[String], 'unique').include
}

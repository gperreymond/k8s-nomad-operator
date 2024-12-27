resource "keycloak_realm" "devops" {
  enabled              = true
  realm                = "devops-team"
  display_name         = "DevOps Team"
  login_theme          = "base"
  access_code_lifespan = "1h"
  internationalization {
    supported_locales = [
      "fr",
      "en",
      "de",
      "es"
    ]
    default_locale = "fr"
  }

  depends_on = [
    null_resource.namespaces,
  ]
}

resource "null_resource" "keycloak" {
  depends_on = [
    null_resource.namespaces,
    keycloak_realm.devops,
  ]
}

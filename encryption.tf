terraform {
  encryption {
    # Add the desired key provider:
    key_provider "pbkdf2" "mykey" {
      # Set passphrase (at least 16 characters long)
      passphrase = var.encryption_passphrase
      # Set up encryption method:
      method "aes_gcm" "talos_method" {
        keys = key_provider.pbkdf2.mykey
      }

      # State encryption:
      state {
        # Link the desired encryption method:
        method = talos_method.aes_gcm.new_method
        # Enforce encryption:
        enforced = true
      }

      # Plan encryption:
      plan {
        # Link the desired encryption method:
        method = talos_method.aes_gcm.new_method
        # Enforce encryption:
        enforced = true
      }
    }
  }
}

# Pagy initializer
require 'pagy/extras/bootstrap'
require 'pagy/extras/overflow'

# Configure Pagy
Pagy::DEFAULT[:items] = 10    # items per page
Pagy::DEFAULT[:size]  = [1,4,4,1] # nav bar links
Pagy::DEFAULT[:overflow] = :last_page # what to do when user requests a page outside range
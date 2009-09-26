##
# Base exception for all Futile exceptions
class Futile::ResistanceIsFutile < Exception
end

##
# Raised on infinite redirection
class Futile::RedirectIsFutile < Futile::ResistanceIsFutile
end

##
# Raised when searching for element didn't succeed:
# * element was not found
# * more than one elements were found
class Futile::SearchIsFutile < Futile::ResistanceIsFutile
end

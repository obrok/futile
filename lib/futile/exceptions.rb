##
# Base exception for all Futile exceptions
#
# @see Futile::ButtonIsFutile
# @see Futile::CheckIsFutile
# @see Futile::RedirectIsFutile
# @see Futile::RequestIsFutile
# @see Futile::SearchIsFutile
# @see Futile::SelectIsFutile
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

##
# Raised when trying to (un)check already (un)checked element
class Futile::CheckIsFutile < Futile::ResistanceIsFutile
end

##
# Raised when clicking a button that is not in a form
class Futile::ButtonIsFutile < Futile::ResistanceIsFutile
end

##
# Raised when selecting a disabled option
class Futile::SelectIsFutile < Futile::ResistanceIsFutile
end

##
# Raised when request was invalid (5xx)
class Futile::RequestIsFutile < Futile::ResistanceIsFutile
end

##
# Raised when an unsupported option is passed to a method
class Futile::OptionIsFutile < Futile::ResistanceIsFutile
end

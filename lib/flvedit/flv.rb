require 'rubygems'
require 'backports'
require 'packable'

# Base & Utilities
require_relative 'flv/util/double_check'
require_relative 'flv/base'

# FLV body of tags
require_relative 'flv/body'
  require_relative 'flv/audio'
  require_relative 'flv/video'
  require_relative 'flv/event'

# FLV chunks (tags & header)
require_relative 'flv/timestamp'
require_relative 'flv/header'
require_relative 'flv/tag'

# packing of FLV objects:
require_relative 'flv/packing'

# finally:
require_relative 'flv/file'
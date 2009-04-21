require 'rubygems'
require 'backports'

# utilities
require_relative 'flv/util/double_check'

# packing of FLV objects:
require 'packable'
require_relative 'flv/packing'
require_relative 'flv/base'

# FLV body of tags
require_relative 'flv/body'
  require_relative 'flv/audio'
  require_relative 'flv/video'
  require_relative 'flv/event'

# FLV chunks (tags & header)
require_relative 'flv/timestamp'
require_relative 'flv/tag'
require_relative 'flv/header'

# finally:
require_relative 'flv/file'
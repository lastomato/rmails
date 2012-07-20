#!/bin/sh
#
# Author: Jie Fan
# Date: 15-Jun-2012
#

PINK=`echo "\033[35m"`
NORMAL=`echo "\033[m"`

EXPECTED_ARGS=2
ERROR_BADARGS=65
if [ $# -ne $EXPECTED_ARGS -o $1 != "new" ]
then
  echo "${PINK}Usage: `echo $0` new <project name>${NORMAL}"
  echo "${PINK}   Ex: `echo $0` new blog${NORMAL}"

  exit $ERROR_BADARGS
fi

CURRENT_DIR=`pwd`
echo "${PINK}Current directory: $CURRENT_DIR${NORMAL}"
echo "${PINK}Begin creating new project...${NORMAL}"

# invoke original command, skip bundle as we'll do manually this later
rails $1 $2 --skip-bundle

echo "${PINK}Done creating base project, doing some configuration now...${NORMAL}"

cd ./$2

# replace default sqlite3 with mongoid and fix js runtime
sed -i "/gem 'sqlite3'/s//# gem 'sqlite3'/g" Gemfile
echo "\ngem 'mongoid'\ngem 'bson_ext'\n\ngroup :development do\n  gem 'execjs'\n  gem 'therubyracer'\nend" >> Gemfile

# bundle install gems
bundle install

echo "${PINK}Done setting up Gemfile, generating mongoid configuration file...${NORMAL}"

# generate config file
rails g mongoid:config

echo "${PINK}Done configuring mongoid, cleaning up...${NORMAL}"

# stop using active_record
sed -i "/require 'rails\/all'/s/^/#/" ./config/application.rb

sed -i "4irequire 'action_controller/railtie'\nrequire 'action_mailer/railtie'\nrequire 'active_resource/railtie'\nrequire 'rails/test_unit/railtie'\nrequire 'sprockets/railtie'" ./config/application.rb

for file in config/application.rb config/environments/*.rb ;do
  sed -i "/[^#].*active_record.*/s/^/#/g" $file
done

echo "${PINK}Done! You are ready to go!${NORMAL}"

web: bundle exec puma -C config/puma.rb -t ${PUMA_MIN_THREADS:-0}:${PUMA_MAX_THREADS:-16} -w ${PUMA_WORKERS:-1} -p $PORT -e ${RACK_ENV:-development}

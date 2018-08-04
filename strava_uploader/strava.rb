#!/usr/local/bin/ruby
require 'ostruct'
require 'pry'
require_relative '.secret/api_keys'

UPPER_BODY_DESCRIPTION = <<~EOF
  Seated Shrugs: 3 sets of 10 reps at 80->90->100
  ...
EOF

LOWER_BODY_DESCRIPTION = <<~EOF
  Pistol Squats: 3 sets of 10 reps at 25->30->35
  ...
EOF

CORE_DESCRIPTION = <<~EOF
  Russian Twists: 2 minutes at 18
EOF

workout_templates = {
  upper: {
    name: "🔫Upper-body Workout💪",
    description: UPPER_BODY_DESCRIPTION,
  },
  lower: {
    name: "⚡️Leg Workout⚡️",
    description: LOWER_BODY_DESCRIPTION, 
  },
  core: {
    name: "🦁Core Workout🦍",
    description: CORE_DESCRIPTION,
  },
  custom: {
    name: "Custom Workout",
    description: '',
  }
  # One could imagine a future where I add, for instance, swimming.
}

# Takes a generic description and adds additions / removes subtractions.
# If subtractions are not in the original description, it does nothing.
def alter_descriptions(description, additions, subtractions)
  new_description = description
  additions.each do |addition|
    stylized_weights = addition.weights.join('->')
    if stylized_weights == ''
      stylized_weights = 'body weight'
    end
    new_description << <<~EOF
      #{addition.exercise}: #{addition.num_sets} sets of #{addition.num_reps} reps at #{stylized_weights}
    EOF
  end
  subtractions.each do |subtraction|
    new_description_array = new_description.split("\n").reject do |line|
      line.index(subtraction) == 0
    end
    new_description = new_description_array.join("\n")
  end

  new_description
end

def parse_options
  if ARGV.empty?
    puts <<~EOF
      You must specify your workout. Here are some examples:
      strava
        -> prints help
      strava upper
        -> posts standard upper body workout
      strava upper +<workout>:<number_of_sets>:<number_of_reps>:<weights>
        -> Adds the following to the description:
        ->  "<workout>: <number_of_sets> sets of <number_of_reps> reps at weight1->weight2->weight3"
      strava upper -<workout>
        -> posts a standard workout, minus that particular thing
      strava upper time:50
        -> Lets you post a workout time, in minutes. It must come AFTER the workout name itself (sorry!)
      strava custom +<workout>:<number_of_sets>:<number_of_reps>:<weights>
        -> does not use any standard template, expects a number of those +<> things.
      strava lower
        -> posts standard leg workout
    EOF
    exit
  elsif ARGV[0] == 'list'
    puts <<~EOF
      Here are the possible templates:
      #{workout_templates}
    EOF
    exit
  elsif ARGV[0] == 'custom'
    puts "You said custom - we're not using any workout template."
  elsif !workout_templates.keys.include?(ARGV[0])
    puts <<~EOF
      #{ARGV[0]} is an invalid argument. The possible values are: [#{workout_templates.keys}].
      Run `strava` with no arguments for a more verbose description.
    EOF
    exit
  end

  workout_type = ARGV[0]
  additions = []
  subtractions= []
  custom_time = nil
  ARGV.each do |argument|
    if argument.start_with?('+')
      addition = OpenStruct.new
      addition.exercise, addition.num_sets, addition.num_reps, weights = argument.slice!(0).split(':')
      addition.weights = weights&.split(',')
      if !addition.exercise || !addition.num_sets || ! addition.num_reps
        puts <<~EOF
          You must specify the exercise, num_sets, and num_reps (and optionally weights), like so:
            exercise:num_sets:num_reps:weights
        EOF
        exit
      end
      if !addition.weights
        puts "No weight specified - that's fine, we'll assume it's using body weight."
      end
      additions << addition
    elsif argument.start_with?('-')
      subtractions << argument.slice!(0)
    elsif argument.index('time:') == 0
      custom_time = argument.split('time:')[1]
    else
      puts "Argument: #{argument} must start with + or - (to denote adding or removing a given workout)."
    end
  end

  [workout_type, additions, subtractions, custom_time]
end

def main(workout_type, description, custom_time)
  strava_url = "https://www.strava.com/api/v3/activities"
  params = {
    name: workout_templates[workout_type][name],
    description: description,
    type: "Workout",
    private: 1,
  }
  params['start_date_local'] = Time.at((activity[start_time_index]/1000).to_i).iso8601
  if custom_time
    params['elapsed_time'] = custom_time * 60
  else
    params['elapsed_time'] = 75*60 # Assume 75 minute workouts (Strava accepts time in seconds)
  end

  strava_auth_header = {Authorization: "Bearer #{STRAVA_API_KEY}"}
  binding.pry
  Requests.request("POST", strava_url, params: params, headers: strava_auth_header)
end

workout_type, additions, subtractions, custom_time = parse_options()
workout_name = workout_templates[workout_type][name]
standard_description = workout_templates[workout_type][description]
customized_description = alter_description(standard_description, additions, subtractions)
main(workout_name, customized_description, custom_time)

# How I'd like to use it:
# strava
#   -> prints help
# strava upper
#   -> posts standard upper body workout
# strava upper +<workout>:<number_of_sets>:<number_of_reps>:<weights>
#   -> Adds the following to the description:
#   ->  "<workout>: <number_of_sets> sets of <number_of_reps> reps at weight1->weight2->weight3"
# strava upper -<workout>
#   -> posts a standard workout, minus that particular thing
# strava custom +<workout>:<number_of_sets>:<number_of_reps>:<weights>
#   -> does not use any standard template, expects a number of those +<> things.
# strava lower
#   -> posts standard leg workout

# The idea being that upper, lower, etc. templates are easily extensible.
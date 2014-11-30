#!/usr/bin/env ruby

require 'json'

IMPORTANCE = [0, 1, 10, 50, 250]

# Returns the 'matching' between two profiles, as per the OkCupid matching algorithm 
def matching (profile_a, profile_b)
	earned_points = 0
 	possible_points = 0

  	profile_a_answers = answer_dictionary(profile_a)
  	profile_b_answers = answer_dictionary(profile_b)
  
  	profile_a_answers.each do |question,answer|
    		# Check if profile_b answered the question
   		if profile_b_answers.include?question
      
     			# If they did, calculate the 'importance' of the question
     			importance = IMPORTANCE[answer['importance']]

     			# Increase the highest possible points
     			possible_points += importance

      			# Check if profile_b's answers include the acceptable answers by profile_a
      			if answer['acceptableAnswers'].include? profile_b_answers[question]['answer']
        			earned_points += importance
     			end
    		end
  	end

	# Return the final 'matching'
	matching = (earned_points).fdiv(possible_points)
end


# Creates a dictionary of answers for any profile with the questionId as a key
def answer_dictionary (profile)
	answers = {}
	profile['answers'].each do |answer|
  		answers[answer['questionId'].to_s] = answer
  	end
  	answers
end

# Returns the top ten matches by score
def top_ten (matches)
	matches.sort_by! { |match| match[:score] }.reverse[0..9]
end

# Returns all the profiles and their top ten matches
def rank_matches (profiles)
	output = { "results" => [] }  # Final result dictionary

	profiles.each do |profile|
        	profile_result = {    # Results for each profile
        		profileId: profile['id'],
       			matches: []
   			}

    		matches = []

    		profiles.each do |other_profile|
      			# Avoid evaluating profile against itself
      			next if other_profile['id'] == profile['id']

      			# Get the 'matching' using the function declared above
     			match_score = Math.sqrt(matching(profile, other_profile) * matching(other_profile, profile))

      			# Add the match to an array of possible matches
      			matches << {
        			profileId: other_profile['id'],
        			score: match_score
     		 	}
    		end

     		# Add only the top 10 matches to the 'matches' array 
      		profile_result[:matches] = top_ten(matches)

      		# Add the results for the profile to the main result dictionary
      		output['results'].push(profile_result)
	end

	# Return the output
	output
end

# Read input JSON
profiles = JSON.parse(STDIN.read)['profiles']

# Rank the matches
matches = rank_matches(profiles)

# Write output JSON - to STDOUT or to a file
STDOUT.write JSON.pretty_generate(matches)
#File.open("output.json","w") {|file| file.write(JSON.pretty_generate(matches))}


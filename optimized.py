import math
import sys
import json
from pqdict import PQDict

IMPORTANCE = [0, 1, 10, 50, 250]

def satisfaction(profile, other_profile):
	
	# Make a dictionary with questionId as key and answer as value
	my_answers = {answer['questionId']: answer for answer in profile['answers']}
	otherp_answers = {answer['questionId']: answer for answer in other_profile['answers']}
    
	correct_points = 0
	possible_points = 0
	for answer in otherp_answers:
		if answer in my_answers:
			# Check if we both answered this question.
			answer_value = IMPORTANCE[my_answers[answer]['importance']]
			possible_points += answer_value
			# Other_profile gets correct points if their answer is in my acceptableAnswers
			if otherp_answers[answer]['answer'] in my_answers[answer]['acceptableAnswers']:
				correct_points += answer_value

	return float(correct_points) / float(possible_points)


def main():

	# Main output dict
	output = {'results': []}

	# Read JSON from file
	with open('input.json', 'r') as f:
		inputjson = json.load(f)

	profiles = inputjson['profiles']
	for profile in profiles:
		pq = PQDict()
		no_of_profiles = 0
		matches=[]
        
		# The output for this profile in JSON format 
		profile_output = {'profileId': profile['id'],
				'matches': []}

		for other_profile in profiles:
			if other_profile['id'] == profile['id']:
			# dont calculate against our own profile
				continue
			# Calculate match percentage with OKCupid's formula
			match_score = math.sqrt(satisfaction(profile, other_profile) * satisfaction(other_profile, profile))

			# Add the first ten matches to a min-heap (PQDict) 
			if len(pq) < 11:
				pq.additem(other_profile['id'],match_score)
			else:
				if match_score > pq.popitem()[1]:
					pq.additem(other_profile['id'],match_score)
				else:
					continue
	
		for i in range(len(pq)):
			key,value = pq.popitem()
			temp = {'profileId': key,
				'score': value}
			matches.append(temp)

        	# Reverse the heap and store it in the output for that profile
        	profile_output['matches'] = matches[::-1]
        	output['results'].append(profile_output)

	# Write out the output JSON to file
	with open('output_optimized.json', 'w') as outf:
		json.dump(output, outf, indent=1)

	return 0


if __name__ == '__main__':
	sys.exit(main())


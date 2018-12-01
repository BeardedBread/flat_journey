extends Node
static func bound_val(val, lower, upper):
	return min(max(val,lower),upper)

static func logistic_func(x, x0=0, k=1):
	return 1/(1+pow(1.6,-k*(x - x0)))

static func randint(lower, upper):
	return randi() % (upper - lower + 1) + lower
	
static func within_bounds(val, lower, upper, inclusive = true):
	if inclusive:
		return val<=upper and val>=lower
	else:
		return val<upper and val>lower
		
static func roll_die(n_times=1, n_sides=6):
	assert n_times > 0
	assert n_sides >= 1
	var total = 0
	for i in range(n_times):
		total += randint(1, n_sides)
	return total
		
static func random_choice_index(chances):
	var sum_chances = 0
	for val in chances:
		sum_chances += val
	var random_chance = randint(1, sum_chances)
	
	var running_sum = 0
	var choice = 0
	for w in chances:
		running_sum += w
		
		if random_chance <= running_sum:
			return choice
		choice += 1
		
static func random_choice_from_dict(choice_dict):
	var choices = choice_dict.keys()
	var chances = choice_dict.values()
	
	return choices[random_choice_index(chances)]

extends Node
static func bound_val(val, lower, upper):
	return min(max(val,lower),upper)

static func logistic_func(x, x0=0, k=1):
	return 1/(1+pow(1.6,-k*(x - x0)))

static func randint(lower, upper):
	# Inclusive random integer
	return randi() % (upper - lower + 1) + lower
	
static func within_bounds(val, lower, upper, inclusive = true):
	if inclusive:
		return val<=upper and val>=lower
	else:
		return val<upper and val>lower

static func rng_check(prob):
	assert (prob <= 1)
	return randf() < prob

static func flip_coin():
	return randint(0,1) == 1
		
static func roll_die(n_times=1, n_sides=6):
	assert (n_times > 0)
	assert (n_sides >= 1)
	var total = 0
	for i in range(n_times):
		total += randint(1, n_sides)
	return total
		
static func inv_negexp(A, B):
	return A * (1-exp(-B))
	
static func negexp(A, B):
	return A * exp(-B)

static func calc_wall_speed(wall_density):
	# Returns positive value
	var spd = 4 + min(Global.wall_difficulty*0.4,4)
	if wall_density > 1:
		spd /= bound_val(wall_density*0.45, 1, 5)
	return spd

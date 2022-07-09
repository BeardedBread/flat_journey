extends Node

const GRID_SIZE = 16
const LOWEST_GRID = 0
const HIGHEST_GRID = 30
const WALL_WIDTH = 64
const LASER_TIMER = 0.25 # This is the time for a frame of laser
const LASER_FRAMES = 4
# A laser has 4 frames, so a laser takes 1 second to fire.


var loading_game = false

var high_score = 0

var start_level = 1

var diff_level = start_level
var wall_difficulty = 1
var laser_difficulty = 1

var level_duration = 10

var return_to_menu = false
var playable = true


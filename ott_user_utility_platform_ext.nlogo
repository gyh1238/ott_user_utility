breed [ users user ]

globals[
  platform_matching_technology_list
  provider_contets_price_list
  platform_subscription_fee_list
  platform_genre_list
  big_number
  platform_shape_list

  contents_in_genre_list
  utility_platform_serving_list

;  list of variables in interface
;  number_of_user
;  number_of_platform
;  number_of_genre
;  number_of_platform_served_genre
;  current_number_of_platform
]

users-own[
  disutility_list
  utility_list
  sub_platform_list

  temp_sub_platform_list
  temp_genre_list
  temp_utility_sum
]

to setup
  clear-all
  init-global-variables
  init-users
  update-variables

  set current_number_of_platform 3
  reset-ticks
end

to go
  update-variables
  calc-users-utility
  calc-users-shape

;   platform
  set current_number_of_platform current_number_of_platform + 1

;   contents

;  set number_of_genre number_of_genre + 1
;  show platform_matching_technology_list

  tick
end

to init-global-variables
;  init with constant value
;  set platform_matching_technology_list n-values number_of_platform [ 1.0 ]
  set provider_contets_price_list       n-values number_of_genre    [ 0.75 ]
  set platform_subscription_fee_list    n-values number_of_platform [ 0.1 ]

;  init with random
  set platform_genre_list               n-values number_of_platform [ random-n-genre number_of_platform_served_genre ]

;  init with constant weight
;  set platform_matching_technology_list ( list 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 )
;  set provider_contets_price_list       ( list 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 )
;  set platform_subscription_fee_list    ( list 0.1 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 )

  let mathing_damping ( 0.8 - ( ( number_of_genre - 6 ) / 72 ) )
  set platform_matching_technology_list (n-values number_of_platform [ mathing_damping ])

  set big_number 10000
  set platform_shape_list [ "netflix" "watcha" "wavve" "tving" "kakao" ]
end

to init-users
;   random location
;  create-users number_of_user [
;    setxy random-xcor random-ycor
;    set disutility_list n-values number_of_platform [ random-float 1 ]
;    set utility_list    n-values number_of_platform [ -1.0 ]
;  ]
;  ask patches [
;    set pcolor white
;  ]

;  lattice location
  ask patches [
    set pcolor white
    sprout-users 1 [
      set disutility_list   n-values number_of_platform [ random-float 1 ]
      set utility_list      n-values number_of_platform [ -1.0 ]
      set sub_platform_list n-values number_of_platform [ 0 ]
      set heading 0
      set color   0
      set size    1.4
    ]
  ]
end

to-report random-n-genre [ number_of_served_genre ]
  let genre_list  ( n-of number_of_served_genre ( range number_of_genre ) )
  let result_list ( n-values number_of_genre [ 0 ] )
  set result_list ( map [ x -> (replace-item x result_list 1) ]  genre_list )
  set result_list ( reduce [ [list1 list2] -> (map + list1 list2) ]  result_list )
  report result_list
end

to update-variables
  let temp_1_list n-values number_of_genre [ 1.0 ]
  set contents_in_genre_list ( map - temp_1_list provider_contets_price_list )
  set contents_in_genre_list ( map * contents_in_genre_list contents_in_genre_list )
  let temp_contents_in_genre_list ( n-values number_of_platform [ contents_in_genre_list ] )
  set utility_platform_serving_list ( map [ [list1 list2] -> ( map * list1 list2 ) ] temp_contents_in_genre_list platform_genre_list )
  set utility_platform_serving_list ( map sum utility_platform_serving_list )
  set utility_platform_serving_list ( map  *  utility_platform_serving_list platform_matching_technology_list )
  set utility_platform_serving_list ( map  -  utility_platform_serving_list platform_subscription_fee_list )

  let mathing_damping ( 0.8 - ( ( number_of_genre - 6 ) / 72 ) )
  set platform_matching_technology_list (n-values number_of_platform [ mathing_damping ])
end

to calc-users-utility
  ask users [
    set utility_list ( map - utility_platform_serving_list disutility_list )
    let temp_inf_list n-values number_of_platform [ big_number ]
    let temp_util_list ( map / utility_list temp_inf_list )
    set sub_platform_list ( map ceiling ( temp_util_list ) )
  ]
end

to calc-users-shape
  ask users [
    set shape one-of platform_shape_list
  ]
end

to-report cumulative_utility_sum
;  platform over current number of platform to 0
  let temp_1_list n-values current_number_of_platform [1]
  let temp_0_list n-values ( number_of_platform - current_number_of_platform ) [0]
  let temp_number_of_platform ( sentence temp_1_list temp_0_list)
  let temp_platform_genre_list ( map [x -> n-values number_of_genre [x]] temp_number_of_platform )
  set temp_platform_genre_list ( map [ [list1 list2] -> ( map * list1 list2 ) ] temp_platform_genre_list platform_genre_list)

  ask users [
;    sum of genre that served from subscribing platforms -> binary
    set temp_sub_platform_list ( map [x -> n-values number_of_genre [x]] sub_platform_list )
    set temp_genre_list ( map [ [list1 list2] -> ( map * list1 list2 ) ] temp_sub_platform_list temp_platform_genre_list)
    set temp_genre_list ( reduce [ [list1 list2] -> (map + list1 list2) ]  temp_genre_list )
    let temp_inf_list n-values number_of_genre [ big_number ]
    set temp_genre_list ( map / temp_genre_list temp_inf_list )
    set temp_genre_list ( map ceiling ( temp_genre_list ) )
    let temp_utility_platform_serving_list ( map * contents_in_genre_list temp_genre_list )
    set temp_utility_sum ( sum temp_utility_platform_serving_list )

    let temp_platform_matching_technology_sum ( ( sum platform_matching_technology_list ) / number_of_platform )
;    show temp_platform_matching_technology_sum
    set temp_utility_sum ( temp_utility_sum * temp_platform_matching_technology_sum )

;    sum of disutility from subscribing platforms
    let temp_disutility_list ( map * disutility_list sub_platform_list )
    set temp_disutility_list ( map * temp_disutility_list temp_number_of_platform )
    let temp_disutility_sum ( sum temp_disutility_list )

;    sum of subscription fee from subscribing platforms
    let temp_subscription_fee_list ( map * platform_subscription_fee_list sub_platform_list )
    set temp_subscription_fee_list ( map * temp_subscription_fee_list temp_number_of_platform )
    let temp_subscription_fee_sum ( sum temp_subscription_fee_list )


    set temp_utility_sum ( temp_utility_sum - temp_subscription_fee_sum - temp_disutility_sum )
  ]
  report ( [ temp_utility_sum ] of users )
end
@#$#@#$#@
GRAPHICS-WINDOW
26
44
859
878
-1
-1
25.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
914
59
977
92
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
994
57
1079
90
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1100
57
1167
90
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
944
600
1116
633
number_of_user
number_of_user
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
944
649
1116
682
number_of_platform
number_of_platform
0
40
20.0
1
1
NIL
HORIZONTAL

SLIDER
941
695
1113
728
number_of_genre
number_of_genre
0
30
9.0
1
1
NIL
HORIZONTAL

SLIDER
889
759
1160
792
number_of_platform_served_genre
number_of_platform_served_genre
0
10
3.0
1
1
NIL
HORIZONTAL

PLOT
1236
671
1724
1012
utility_sum_idv
NIL
NIL
-30.0
30.0
0.0
100.0
true
false
"" ";let x_min ( min ( [ ( sum utility_list ) ] of users ) )\n;let x_max ( max ( [ ( sum utility_list ) ] of users ) )\n;set-plot-x-range x_min x_max"
PENS
"pen-0" 1.0 1 -16777216 true "" "histogram [ ( sum utility_list ) ] of users"

PLOT
887
110
1191
342
number_of_sub_ott
NIL
NIL
0.0
20.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [ sum sub_platform_list ] of users"

PLOT
1236
84
1467
261
number of sub each platform
NIL
NIL
0.0
20.0
0.0
1200.0
true
false
"" "clear-plot"
PENS
"default" 1.0 1 -16777216 true "" "foreach ( reduce [ [list1 list2] -> (map + list1 list2) ] ( [ sub_platform_list ] of users ) ) [ [point] -> plot point ]"

PLOT
1605
81
2332
581
cumulative_utility_sum
NIL
NIL
0.0
20.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ( sum cumulative_utility_sum )"

SLIDER
914
827
1142
860
current_number_of_platform
current_number_of_platform
0
20
69.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

kakao
true
0
Rectangle -1184463 true false 30 30 270 285
Circle -16777216 true false 41 41 218
Polygon -16777216 true false 75 225 75 270 120 255 75 225
Polygon -1184463 true false 105 120 90 120 90 150 105 150 105 210 150 210 150 180 120 180 120 150 150 150 150 120 120 120 120 90 105 90 105 120
Polygon -1184463 true false 165 120 180 120 195 165 210 120 225 120 210 210 195 210 180 210 165 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

netflix
true
0
Polygon -2674135 true false 60 60 60 270 105 270 105 150 195 270 240 270 240 60 195 60 195 195 105 60 60 60

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

tving
true
0
Circle -8630108 true false 191 146 67
Circle -2064490 true false 36 36 228
Polygon -1 true false 90 105 225 105 225 150 165 150 165 225 120 225 120 150 60 150 60 105 90 105
Polygon -8630108 true false 60 150 120 195 120 150 60 150
Polygon -8630108 true false 120 225 180 255 255 150 225 105 225 150 165 150 165 225 120 225
Polygon -8630108 true false 255 150 270 180 195 270 180 255 255 150

watcha
true
0
Polygon -2064490 true false 60 120 75 255 105 255 150 165 195 255 225 255 255 75 210 75 210 195 150 120 105 210 90 120 60 120

wavve
true
0
Polygon -13345367 true false 90 60 90 255 240 150 90 60
Polygon -13791810 true false 90 210 90 255 150 210 90 210
Polygon -13345367 true false 90 150 90 210 150 210 195 180 90 150
Polygon -11221820 true false 90 150 90 210 150 210 195 180 90 150

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt; 16</exitCondition>
    <metric>sum cumulative_utility_sum</metric>
    <enumeratedValueSet variable="current_number_of_platform">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_genre">
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_platform">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_user">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_platform_served_genre">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

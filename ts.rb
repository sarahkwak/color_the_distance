require 'httparty'

class ColorQA
	include HTTParty
  base_uri 'http://challenge.teespring.com'

  def self.api_key
    '234b4cb0-fa39-4bca-adb6-47304efb36f3'
  end

  def self.base_url
  	'http://challenge.teespring.com/v1/'
  end

  def self.get_questions
  	url = ColorQA.base_url + "question/evaluate"
  	HTTParty.get(url, headers: {"Auth-Token" => ColorQA.api_key })
  end

  def self.parse_colors
  	responses = ColorQA.get_questions
  	scenario_id = responses["scenario_id"]
  	result = Array.new
  	responses.each do |res|
  		co1 = res['questions']['layers'][0]['color']
  		co1_v = res['questions']['layers'][0]['color']['volume']
  		co2 = res['questions']['layers'][1]['color']
  		co2_v = res['questions']['layers'][1]['color']['volume'] 
  		co_result.push [co1, co2]
  	end
  	co_result
  end

  # I've used 6 dimensions and at the end of the time, I realized that I should've used 3 demensions. 
  # 34A071 p1=34, p2=A0, p3=71
	# 19BB27 is q1=19, q2=BB, q3=27
  def self.n_dimensions_color co1, co2
  	result = []
  	co1 = co1[1..6]
  	co2 = co2[1..6]
  	num_distance = 0 
  	i = 1
  	while i < 7
  		if co1[i] != "0" && co1[i].to_i == 0 
  			co1[i] = co1[i].to_i(16).to_s
  		elsif  co2[i] != "0" && co2[i].to_i == 0 
  			co2[i] = co2[i].to_i(16).to_s
  		end
	  	num_distance += (co1[i].to_i-co2[i].to_i)*(co1[i].to_i-co2[i].to_i)
	  	i+=1
	  end
	  euclidean_distance = Math.sqrt(num_distance).to_i
  end

  def self.get_inks
  	HTTParty.get(ColorQA.base_url+'inks', headers: {"Auth-Token" => ColorQA.api_key })
  end

  def self.each_color_distance
  	colors = ColorQA.parse_colors
  	distances = Array.new
  	colors.each do 
	  	# color = ["#34A071"," #19BB27"]
	  	distances.push ColorQA.n_dimensions_color(color.first, color.last)
	  end
	  distances
  end

  def self.post_practice_answers
  	practice_url = ColorQA.base_url + 'answer/practice'
    HTTParty.post(
    	practice_url, 
    	body: {
    		"comments" => 'It was very hard questions! Thanks for the challenge. First, I parsed HTTParty.get data to the array and then tried to calculate euclidean_distance by convert the colors to integer and using 6_dimentions. Only later I realized that it should be 3_dimension. I have not used inks data so the cost calculation has not been done. Thanks!'
    	}.to_json,
    	headers: {
    	 	"Auth-Token" => ColorQA.api_key 
    	}
    )
  end

  def self.post_evaluate_answers
  	answer_url = ColorQA.base_url + 'answer/evaluate'
  	HTTParty.post(
  		answer_url, 
    	body: {
    		"answer" => ColorQA.each_color_distance
    	}.to_json,
    	headers: {
    	 	"Auth-Token" => ColorQA.api_key 
    	}
  	)
  end

  ColorQA.post_practice_answers
  ColorQA.post_evaluate_answers

end
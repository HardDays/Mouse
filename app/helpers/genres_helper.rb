class GenresHelper

  def self.all
    return [:blues, :children_music, :classical, :country, :electronic, :holiday, :opera, :singer, :jazz,
            :latino, :new_age, :pop, :soul, :musicals, :dance, :hip_hop, :world, :alternative, :rock,
            :christian_gospel, :vocal, :reggae, :easy_listening, :j_pop, :enka, :anime, :kayokyoku, :k_pop,
            :karaoke, :instrumental, :brazilian, :spoken_word, :disney, :french_pop, :german_pop, :german_folk]
  end

  def self.readable_json
    return {
      blues: 'blues',
      children_music: 'children music',
      classical: 'classical',
      country: 'country',
      electronic: 'electronic',
      holiday: 'holiday',
      opera: 'opera',
      singer: 'singer/songwriter',
      jazz: 'jazz',
      latino: 'latino',
      new_age: 'new age',
      pop: 'pop',
      soul: 'r&b/soul',
      musicals: 'musicals',
      dance: 'dance',
      hip_hop: 'hip-hop/rap',
      world: 'world',
      alternative: 'alternative',
      rock: 'rock',
      christian_gospel: 'christian & gospel',
      vocal: 'vocal',
      reggae: 'reggae',
      easy_listening: 'easy listening',
      j_pop: 'j-pop',
      enka: 'enka',
      anime: 'anime',
      kayokyoku: 'kayokyoku',
      k_pop: 'k-pop',
      karaoke: 'karaoke',
      instrumental: 'instrumental',
      brazilian: 'brazilian',
      spoken_word: 'spoken word',
      disney: 'disney',
      french_pop: 'french pop',
      german_pop: 'german pop',
      german_folk: 'german folk',
    }
  end
end

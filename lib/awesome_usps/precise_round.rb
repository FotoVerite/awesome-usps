module PreciseRound
  def precise_round(precision=0)
    if precision > 0
      (self * (10**precision)).round.to_f / (10**precision)
    else
      self.round
    end
  end
end

Float.send(:include, PreciseRound)
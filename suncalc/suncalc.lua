local SunCalc = {}

SunCalc.RAD = math.pi / 180
SunCalc.DAY_MS = 1000 * 60 * 60 * 24
SunCalc.J1970 = 2440588
SunCalc.J2000 = 2451545
SunCalc.E = RAD * 23.4397
SunCalc.J0 = 0.0009
SunCalc.SDIST = 149598000
SunCalc.HC = 0.133 * RAD

SunCalc.TIMES = {
	{-0.833, "sunrise", "sunset"},
	{-0.3, "sunrise_end", "sunset_start"},
	{-6, "dawn", "dusk"},
	{-12, "nautical_dawn", "nautical_dusk"},
	{-18, "night_end", "night"},
	{6, "golden_hour_end", "golden_hour"}
    }

function SunCalc:new (o)
	o = o or {}
	o.latitude = o.latitude or 48.58
	o.longitude = o.longitude or 10.49
  
	setmetatable(o, self)
	self.__index = self

	return o
end
 
function SunCalc:to_julian(date) -- return type(number) of julian year
	return date / (self.DAY_MS/1000) - 0.5 + self.J1970
end

function SunCalc:from_julian(j) -- return type(number) of sec (epoch)
	return (j + 0.5 - self.J1970) * (self.DAY_MS/1000)
end

function SunCalc:to_days(date)
	return self.to_julian(date) - self.J2000
end

function SunCalc:get_sun_hight ()
	local lw = self.RAD * - self.longitude
	local phi = self.RAD * self.latitude
	local d = os.time()
	local c = self.sun_coords(d)
	local h = self.sidereal_time(d, lw) - c.ra
	local az = azimuth(h, phi, c.dec)
	local al = altitude(h, phi, c.dec)
	return { azimuth=az, altitude=al }
end

--[=[


    # General calculations for position

    def self.right_ascension(l, b)
        Math::atan2(Math::sin(l) * Math::cos(E) - Math::tan(b) * Math::sin(E), Math::cos(l))
    end

    def self.declination(l, b)
        Math::asin(Math::sin(b) * Math::cos(E) + Math::cos(b) * Math::sin(E) * Math::sin(l))
    end

    def self.azimuth(h, phi, dec)
        Math::atan2(Math::sin(h), Math::cos(h) * Math::sin(phi) - Math::tan(dec) * Math::cos(phi))
    end

    def self.altitude(h, phi, dec)
        Math::asin(Math::sin(phi) * Math::sin(dec) + Math::cos(phi) * Math::cos(dec) * Math::cos(h))
    end

    def self.sidereal_time(d, lw)
        RAD * (280.16 + 360.9856235 * d) - lw
    end

    # General sun calculations
    def self.solar_mean_anomaly(d)
        RAD * (357.5291 + 0.98560028 * d)
    end

    def self.ecliptic_longitude(m)
        c = RAD * (1.9148 * Math::sin(m) + 0.02 * Math::sin(2 * m) + 0.0003 * Math::sin(3 * m))
        p = RAD * 102.9372

        m + c + p + Math::PI
    end

    def self.sun_coords(d)
        @result = []
        sM = solar_mean_anomaly(d)
        eL = ecliptic_longitude(sM)


        { :dec => declination(eL, 0),
          :ra => right_ascension(eL, 0)
        }
    end

    # Calculate sun position for a given date and latitude/longitude
    def self.get_position(date, lat, lng)
        lw = RAD * -lng
        phi = RAD * lat
        d = to_days(date)
        c = sun_coords(d)
        h = sidereal_time(d, lw) - c[:ra]

        { :azimuth => azimuth(h, phi, c[:dec]),
          :altitude => altitude(h, phi, c[:dec])
        }
    end

    # Sun times configuration (angle, morning name, evening name)

    def self.add_time(angle, rise_name, set_name)
        TIMES << [angle, rise_name, set_name]
    end

    # Calculations for sun times
    def self.julian_cycle(d, lw)
        (d - J0 - lw / (2 * Math::PI)).round
    end

    def self.approx_transit(ht, lw, n)
        J0 + (ht + lw) / (2 * Math::PI) + n
    end

    def self.solar_transit_j(ds, m, l)
        J2000 + ds + 0.0053 * Math::sin(m) - 0.0069 * Math::sin(2 * l)
    end

    def self.hour_angle(h, phi, d)
        Math::acos((Math::sin(h) - Math::sin(phi) * Math::sin(d)) / (Math::cos(phi) * Math::cos(d)))
    end

    # Returns set time for the given sun altitude
    def self.get_set_j(h, lw, phi, dec, n, m, l)
        w = hour_angle(h, phi, dec)
        a = approx_transit(w, lw, n)
        solar_transit_j(a, m, l)
    end

    # Calculate sun times for a given date and latitude/longitude
    def self.get_times(date, lat, lng)
        lw = RAD * -lng
        phi = RAD * lat
        
        d = to_days(date)
        n = julian_cycle(d, lw)
        ds = approx_transit(0, lw, n)
        
        m = solar_mean_anomaly(ds)
        l = ecliptic_longitude(m)
        dec = declination(l, 0)

        jnoon = solar_transit_j(ds, m, l)

        result = {
            :solar_noon => from_julian(jnoon),
            :nadir => from_julian(jnoon - 0.5)
        }

        TIMES.each do |time|
            jset = get_set_j(time[0] * RAD, lw, phi, dec, n, m, l)
            jrise = jnoon - (jset - jnoon)
           
            result[time[1]] = from_julian(jrise)
            result[time[2]] = from_julian(jset)
        end

        result
    end

    # Moon calculations
    def self.moon_coords(d)
        el = RAD * (218.316 + 13.176396 * d)
        m = RAD * (134.963 + 13.064993 * d)
        f = RAD * (93.272 + 13.229350 * d)

        l = el + RAD * 6.289 * Math::sin(m)
        b = RAD * 5.128 * Math::sin(f)
        dt = 385001 - 20905 * Math::cos(m)
        

        result = {
            :ra => right_ascension(l, b),
            :dec => declination(l, b),
            :dist => dt
        }

        result
    end

    def self.get_moon_position(date, lat, lng)
        lw = RAD * -lng
        phi = RAD * lat
        d = to_days(date)

        c = moon_coords(d)
        th = sidereal_time(d, lw) - c[:ra]
        h = altitude(th, phi, c[:dec])
        
        h = h + RAD * 0.017 / Math::tan(h + RAD * 10.26 / (h + RAD * 5.10))
        
        result = {
            :azimuth => azimuth(th, phi, c[:dec]),
            :altitude => h,
            :distance => c[:dist]
        }

        result
    end

    # Calculations for illumination parameters of the moon
    def self.get_moon_illumination(date)
        d = to_days(date)
        s = sun_coords(d)
        m = moon_coords(d)

        phi = Math::acos(Math::sin(s[:dec]) * Math::sin(m[:dec]) + Math::cos(s[:dec]) * Math::cos(m[:dec]) * Math::cos(s[:ra] - m[:ra]))
        inc = Math::atan2(SDIST * Math::sin(phi), m[:dist] - SDIST * Math::cos(phi))
        angle = Math::atan2(Math::cos(s[:dec]) * Math::sin(s[:ra] - m[:ra]), Math::sin(s[:dec]) * Math::cos(m[:dec]) - Math::cos(s[:dec]) * Math::sin(m[:dec]) * Math::cos(s[:ra] - m[:ra]))

        result = {
            :fraction => (1 + Math::cos(inc)) / 2,
            :phase => 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Math::PI,
            :angle => angle
        }

        result
    end

    def self.hours_later(date, h)
        Time.at(date.to_f + (h * (DAY_MS/1000)) / 24).utc 
    end

    def self.get_moon_times(date, lat, lng)
        t = Time.new(date.year.to_i, date.month.to_i, date.day.to_i).utc
        h0 = get_moon_position(t, lat, lng)[:altitude] - HC

        rise = false
        set = false
        ye = 0

        (1..24).step(2) do |i|
            h1 = get_moon_position(hours_later(t, i), lat, lng)[:altitude] - HC
            h2 = get_moon_position(hours_later(t, i + 1), lat, lng)[:altitude] - HC 

            a = (h0 + h2) / 2 - h1
            b = (h2 - h0) / 2
            xe = -b / (2 * a)
            ye = (a * xe + b) * xe + h1
            d = b * b - 4 * a * h1
            
            roots = 0

            if d >= 0
                dx = Math::sqrt(d) / (a.abs * 2)

                x1 = xe - dx
                x2 = xe + dx

                if x1.abs <= 1 
                    roots += 1
                end
                
                if x2.abs <= 1
                    roots += 1
                end

                if x1 < -1
                    x1 = x2
                end
            end

            if roots === 1
                if h0 < 0
                    rise = i + x1
                else
                    set = i + x1
                end
            elsif roots === 2
                rise = i + (ye < 0 ? x2 : x1)
                set = i + (ye < 0 ? x1 : x2)
            end
            
            break if rise and set

            h0 = h2
        end

        result = {}
        if rise
            result[:rise] = hours_later(t, rise)
        end
        
        if set
            result[:set] = hours_later(t, set)
        end

        if not rise and not set
            result[ye > 0 ? :alwaysUp : :alwaysDown] = true
        end

        result
    end
end
--]=]


  
return SunCalc

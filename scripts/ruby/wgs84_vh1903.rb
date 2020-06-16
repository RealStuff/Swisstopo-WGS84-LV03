# The MIT License (MIT)
#
# Copyright (c) 2014 Federal Office of Topography swisstopo, Wabern, CH
# Copyright (c) 2017 Michael Monay https://github.com/micmonay
# Copyright (c) 2019 Bernhard Flühmann, Realstuff Informatik AG, Bern, CH, https://www.realstuff.ch
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#

class Swisstopo

    # Convert CH (LVS 03 and LV95) to WGS84 Return a array of double that contain lat, long,
    # and height
    #
    # @param east
    # @param north
    # @param height
    # @return
    #
    def CHtoWGS84(east, north, height)
        
        # Remove LV95 east offset
        offsetEast = 2000000
        if east >= offsetEast
            east = east - offsetEast
        end

       # Remove LV95 north offset
       offsetNorth = 1000000
       if north >= offsetNorth
           north = north - offsetNorth
       end

        d = Array.new(3)
        
        d.insert(0, CHtoWGSlat(east, north))
        d.insert(1, CHtoWGSlng(east, north))
        d.insert(2, CHtoWGSheight(east, north, height))
        return d
    end
 
    # Convert WGS84 to LV95 Return an array of double that contain east,
    # north, and height
    #
    # @param latitude
    # @param longitude
    # @param ellHeight
    # @return
    #
    def WGS84toLV95(lat, lng, ellHeight)

        lv03 = WGS84toLV03(lat, lng, ellHeight)

        offsetEast = 2000000
        offsetNorth = 1000000
 
        lv95 = Array.new(3)

        lv95.insert(0, (lv03[0] + offsetEast))
        lv95.insert(1, (lv03[1] + offsetNorth))
        lv95.insert(2, lv03[2])

        return lv95

    end

    # Convert WGS84 to LV03 Return an array of double that contain east,
    # north, and height
    #
    # @param latitude
    # @param longitude
    # @param ellHeight
    # @return
    #
    def WGS84toLV03(lat, lng, ellHeight)
 
        d = Array.new(3)
    
        d.insert(0, WGStoCHy(lat, lng))
        d.insert(1, WGStoCHx(lat, lng))
        d.insert(2, WGStoCHheight(lat, lng, ellHeight))
        return d
    end

    # Convert CH y/x to WGS lat
    def CHtoWGSlat(y, x)
        # Converts military to civil and to unit = 1000km
        # Auxiliary values (% Bern)
        Float y_aux = (y - 600000) / 1000000
        Float x_aux = (x - 200000) / 1000000
        
        # Process lat
        Float lat = (16.9023892 + (3.238272 * x_aux)) - (0.270978 * y_aux**2) - (0.002528 * x_aux**2) - (0.0447 * y_aux**2 * x_aux) - (0.0140 * x_aux**3)
        
        # Unit 10000" to 1 " and converts seconds to degrees (dec)
        lat = (lat * 100) / 36
        
        return lat
    end
    
    # Convert CH y/x to WGS long
    def CHtoWGSlng(y, x)
        # Converts military to civil and to unit = 1000km
        # Auxiliary values (% Bern)
        y_aux = (y - 600000) / 1000000
        x_aux = (x - 200000) / 1000000
        
        # Process long
        lng = (2.6779094 + (4.728982 * y_aux) + (0.791484 * y_aux * x_aux) + (0.1306 * y_aux * x_aux**2)) - (0.0436 * y_aux**3)
        
        # Unit 10000" to 1 " and converts seconds to degrees (dec)
        lng = (lng * 100) / 36
        
        return lng
    end
    
    def CHtoWGSheight(y, x, h)
        # Converts military to civil and to unit = 1000km
        # Auxiliary values (% Bern)
        Float y_aux = (y - 600000) / 1000000
        Float x_aux = (x - 200000) / 1000000
    
        # Process height
        h = (h + 49.55) - (12.60 * y_aux) - (22.64 * x_aux)
    
        return h
    end
    
    # Convert WGS lat/long (° dec) to CH x
    def WGStoCHx(lat, lng)
        # Converts dec degrees to sex seconds
        lat = DecToSexAngle(lat)
        lng = DecToSexAngle(lng)
    
        # Auxiliary values (% Bern)
        lat_aux = (lat - 169028.66) / 10000
        lng_aux = (lng - 26782.5) / 10000
    
        # Process X
        x = ((200147.07 + (308807.95 * lat_aux) + (3745.25 * lng_aux**2) + (76.63 * lat_aux**2)) - (194.56 * lng_aux**2 * lat_aux)) + (119.79 * lat_aux*3)
    
        return x
    end

   # Convert WGS lat/long (° dec) to CH y
    def WGStoCHy(lat, lng)
        # Converts dec degrees to sex seconds
        lat = DecToSexAngle(lat)
        lon = DecToSexAngle(lng)
    
        # Auxiliary values (% Bern)
        lat_aux = (lat - 169028.66) / 10000
        lng_aux = (lon - 26782.5) / 10000
    
        # Process Y
        y = (600072.37 + (211455.93 * lng_aux)) - (10938.51 * lng_aux * lat_aux) - (0.36 * lng_aux * lat_aux**2 - lng_aux**3)
    
        return y
    end

    # Convert WGS lat/long (° dec) and height to CH h
    def WGStoCHheight(lat, lng, h)
        # Converts dec degrees to sex seconds
        lat = DecToSexAngle(lat)
        lng = DecToSexAngle(lng)
        
        # Auxiliary values (% Bern)
        lat_aux = (lat - 169028.66) / 10000
        lng_aux = (lng - 26782.5) / 10000
        
        # Process h
        h = (h - 49.55) + (2.73 * lng_aux) + (6.94 * lat_aux)
        
        return h
    end

    # Convert decimal angle (degrees) to sexagesimal angle (seconds)
    def DecToSexAngle (dec)
        deg = dec.floor
        min = ((dec - deg) * 60).floor
        sec = (((dec - deg) * 60) - min) * 60
        
        return sec + min*60.0 + deg*3600.0
    end
end
//
//  https://mczachurski.dev
//  Code created based on library: https://github.com/mourner/suncalc
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public class SunCalculations {
    
    private let imageLocation: ImageLocation

    private let rad = Double.pi / 180.0
    private let daySec = 60 * 60 * 24.0
    private let J1970 = 2440588.0
    private let J2000 = 2451545.0
    
    // obliquity of the Earth
    private let e = (Double.pi / 180.0) * 23.4397
    
    public init(imageLocation: ImageLocation) {
        self.imageLocation = imageLocation
    }
    
    public func getSunPosition() -> SunPosition {
        let lw = self.rad * (-self.imageLocation.longitude)
        let phi = self.rad * self.imageLocation.latitude
        let days = self.toDays(date: self.imageLocation.createDate)
        
        let c = self.sunCoords(days: days);
        let h = self.siderealTime(days, lw) - c.rightAscension
        
        let radAzimuth = self.azimuth(h, phi, c.declination)
        let radAltitude = self.altitude(h, phi, c.declination)
        
        let altitude = (radAltitude * 180) / Double.pi
        let azimuthFromSouth = (radAzimuth * 180) / Double.pi

        var azimuth = azimuthFromSouth + 180
        if azimuth > 360 {
            azimuth = azimuth - 360
        }
        
        return SunPosition(azimuth: azimuth, altitude: altitude)
    }
    
    private func sunCoords(days: Double) -> SunCoordinates {
        
        let m = self.solarMeanAnomaly(days: days)
        let l = self.eclipticLongitude(solarMeanAnomaly: m);

        let declination = self.declination(l, 0)
        let rightAscension = self.rightAscension(l, 0)
        
        return SunCoordinates(declination: declination, rightAscension: rightAscension);
    }
    
    private func toDays(date: Date) -> Double {
        let julianDate = self.toJulian(date: date)
        return julianDate - self.J2000
    }

    private func toJulian(date: Date) -> Double {
        return (date.timeIntervalSince1970 / self.daySec) - 0.5 + self.J1970
    }
    
    private func solarMeanAnomaly(days: Double) -> Double {
        return self.rad * (357.5291 + 0.98560028 * days)
    }
    
    private func eclipticLongitude(solarMeanAnomaly m: Double) -> Double{
        let c = self.rad * (1.9148 * sin(m) + 0.02 * sin(2 * m) + 0.0003 * sin(3 * m)); // equation of center
        let p = rad * 102.9372; // perihelion of the Earth

        return m + c + p + Double.pi;
    }
    
    private func declination(_ l: Double, _ b: Double) -> Double {
        return asin(sin(b) * cos(e) + cos(b) * sin(self.e) * sin(l))
    }
    
    private func rightAscension(_ l: Double, _ b: Double) -> Double {
        return atan2(sin(l) * cos(self.e) - tan(b) * sin(self.e), cos(l))
    }
    
    private func siderealTime(_ days: Double, _ lw: Double) -> Double {
        return self.rad * (280.16 + 360.9856235 * days) - lw
    }
    
    private func azimuth(_ h: Double, _ phi: Double, _ dec: Double) -> Double {
        return atan2(sin(h), cos(h) * sin(phi) - tan(dec) * cos(phi))
    }
    
    private func altitude(_ h: Double, _ phi: Double, _ dec: Double) -> Double {
        return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(h))
    }
}

#!/usr/bin/python
# r.out.gmt.py - converts a GRASS raster to GMT
#
# David Finlayson
# david.p.finlayson@gmail.com
# 
# October 1, 2005
#
# Version 0.1.1
# 
#
# Notes: 
#
# This script is designed to make converting from GRASS to GMT painless. Set up
# your region and resolution in GRASS and then execute this script. If all goes
# well, this script will convert your raster to GMT format (including the
# colormap), place a simple graticule around the frame and add a north arrow and
# legend. You can then go in and edit the script to make a good looking map. 
# This should be much easier than starting from scratch.
#
# You can contol how large the map is by adjusting the MAX_DIMENSION constant
# below. You can easily hard-code modifications into the script and make your
# work easier.
#
# TO DO:
#
# It may be fairly easy to detect the GMT page size and do an automatic conversion
# from map to page units. Then I can eliminate one of the commandline parameters.
# Unfortunately, writing a conversion from GRASS projections to GMT projections
# would be a hugh pain in the rear. The solution now is to force the user to look
# up the relevant details.
#
# I'd like to refine the placement and size of map decorations so that suitable
# defaults are produced. Currently, it just dumps them into the file without
# much thought.
#
# David
#
# Update History:
#
# July 17, 2005 -   Version 0.1 released
# October 1, 2005 - Fixed a few bugs

import os, sys
from optparse import OptionParser

# Constants
MAX_DIMENSION = 14 # maximum height or width in inches

class GrassRaster:
   def __init__(self, name):
      self.name = name
      self.get_info()
   
   def get_info(self):
      # Get the bounding coordinates in northing/easting format
      env = os.popen('g.region -gp')
      self.n = float(env.readline().split('=')[1].strip())
      self.s = float(env.readline().split('=')[1].strip())
      self.w = float(env.readline().split('=')[1].strip())
      self.e = float(env.readline().split('=')[1].strip())
      self.nsres = float(env.readline().split('=')[1].strip())
      self.ewres = float(env.readline().split('=')[1].strip())
   
      # Get the bounding coordinates in latitude/longitude format
      envll = os.popen('g.region -gpl')
      ll = envll.readlines()
      self.lonll = float(ll[3].split()[1])
      self.latll = float(ll[3].split()[3])
      self.lonur = float(ll[1].split()[1])
      self.latur = float(ll[1].split()[3])
      self.rows = int(ll[4].split()[1])
      self.cols = int(ll[5].split()[1])
      
      # Get the location of the raster file
      gisenv = os.popen('g.gisenv')
      self.dbase = gisenv.readline().split('=')[1].strip()[1:-2]
      self.location = gisenv.readline().split('=')[1].strip()[1:-2]
      self.mapset = gisenv.readline().split('=')[1].strip()[1:-2]
      
      # Get the type of the raster
      info = os.popen("r.info -t map=%s" % self.name)
      self.type = info.read()[9:].strip()
      
      # Get the range
      info = os.popen('r.info -r map=%s' % self.name)
      self.zmin = float(info.readline().split('=')[1])
      self.zmax = float(info.readline().split('=')[1])
      
      # Get the projection
      # info = os.popen('g.proj -p')
      # self.projname = info.readline().split(":")[1].strip()
      # self.datum = info.readline().split(":")[1].strip()
      # self.nadgrids = info.readline().split(":")[1].strip()
      # self.proj = info.readline().split(":")[1].strip()
      # self.ellps = info.readline().split(":")[1].strip()
      # self.a = float(info.readline().split(":")[1].strip())
      # self.es = float(info.readline().split(":")[1].strip())
      # self.f = float(info.readline().split(":")[1].strip())
      # self.zone = int(info.readline().split(":")[1].strip())
      # info.readline()
      # self.unit = info.readline().split(":")[1].strip()
      # self.units = info.readline().split(":")[1].strip()
      # self.meters = info.readline().split(":")[1].strip()

   def gmt_region(self):
      # Return the region in map units
      R = "-R%s/%s/%s/%s" % (self.w, self.e, self.s, self.n)
      return(R)
      
   def gmt_region_ll(self):
      # return the region in longitude/latitude
      R = "-R%s/%s/%s/%sr" % (self.lonll, self.latll, self.lonur, self.latur)
      return(R)
      
   def gmt_colormap(self, colormapname):  
      # returns a gmt-compatible colormap
      fin = open(os.path.join(self.dbase, self.location, self.mapset, "colr", self.name))
      data = fin.read()
      fin.close()
      
      # Simple header
      o = "#  cpt file copied from GRASS by r.out.gmt.py\n#Color_MODEL = RGB\n#\n"
      
      # Loop through the grass colormap file and convert to GMT format
      counter = 1
      nodata_red = 255
      nodata_green = 255
      nodata_blue = 255
      for set in data.split():
         definition = set.split(":")
         if len(definition) == 1: continue
         
         if definition[0] == "nv" and len(definition) == 4:
            nodata_red = definition[1]
            nodata_green = definition[2]
            nodata_blue = definition[3]
            continue
         elif definition[0] == "nv" and len(definition) == 2:
            nodata_red = definition[1]
            nodata_green = definition[1]
            nodata_blue = definition[1]
            continue
         elif len(definition) == 4:
            value = definition[0]
            red = definition[1]
            green = definition[2]
            blue = definition[3]
         elif len(definition) == 2:
            value = definition[0]
            red = definition[1]
            green = definition[1]
            blue = definition[1]
         else:
            print "Error: I don't know how to interpret this color file:"
            print set
            print data
            sys.exit(0)
         
         # write out the line (newlines with every other write)
         if counter % 2 == 0:
            o = o + "%s\t%s\t%s\t%s\n" % (value, red, green, blue)
         else:
            o = o + "%s\t%s\t%s\t%s\t" % (value, red, green, blue)
         counter = counter + 1

      # Write out the nodata color value
      o = o + "N\t%s\t%s\t%s\n" % (nodata_red, nodata_green, nodata_blue)
      fout = open(colormapname, 'w')
      fout.write(o)
      fout.close()
      return()
      
   def gmt_convert(self, gmtname):
      # Convert the grid to GMT format
      
      if self.type == "DCELL":
         os.system("r.out.bin input=%s output=- | xyz2grd -G%s -R%s/%s/%s/%s -I%s/%s -ZTLd -F" % (self.name, gmtname + \
            ".grd", self.w, self.e, self.s, self.n, self.ewres, self.nsres))
      elif self.type == "FCELL":
         os.system("r.out.bin input=%s output=- | xyz2grd -G%s -R%s/%s/%s/%s -I%s/%s -ZTLf -F" % (self.name, gmtname + \
            ".grd", self.w, self.e, self.s, self.n, self.ewres, self.nsres))
      elif self.type == "CELL":
         os.system("r.out.bin input=%s output=- | xyz2grd -G%s -R%s/%s/%s/%s -I%s/%s -ZTLh -F" % (self.name, gmtname + \
            ".grd", self.w, self.e, self.s, self.n, self.ewres, self.nsres))
      else:
         print "ERROR: I don't know how to convert rasters of type: %s" % self.type
         sys.exit()

def get_options():
   # Command line options
   if len(sys.argv) == 4:
      projection = sys.argv[1]
      raster = sys.argv[2]
      convert = sys.argv[3]
      shade = None
   elif len(sys.argv) == 5:
      projection = sys.argv[1]
      raster = sys.argv[2]
      convert = sys.argv[3]
      shade = sys.argv[4]
   else:
      print """ 
      USAGE: r.out.gmt.py <projection> <raster> <conversion> [<intensity>]
      
      <projection> - GMT projection string. See the man page
                     for psbasemap -J options. Do not include the scale, this
                     will be determined automatically. For example, a GRASS 
                     raster in UTM zone 10 north is represented in psbasemap 
                     by the string -Ju10 (we leave off the scale aurgument). 
                     Washington State Plane is a Lambert conformal conic 
                     projection, it would be entered here as 
                     -Jl-120:50/47/48:44/47:30 (again, we leave off the scale 
                     aurgument).
      
      <raster> -     name of raster map to export to GMT
      <conversion> - the conversion from GRASS map units to GMT page
                     units. Common examples:
                        
                     Grass Map Unit   GMT Page Unit   Conversion
                     --------------   -------------   -----------
                     m                cm              100.0
                     m                in              39.37
                     ft               cm              30.48
                     ft               in              12.00
                     
      <intensity> -  optional, include an intensity map such as a
                     shaded relief map. Hue is taken from the colormap
                     of <raster> while intensity is taken from <intensity>.
                    
      """
      sys.exit(0)
   return([projection, raster, convert, shade])

def set_environment():
   # Set up the environment variables
   os.environ['PATH'] = os.environ['PATH'] + r':/usr/local/GMT4.0/bin'
   os.environ['GMTHOME'] = r'/usr/local/GMT4.0'
   os.environ['MANPATH'] = r'/usr/local/GMT4.0/man:$MANPATH'

def main():
   # Get the commandline options
   opts = get_options()
   projection = opts[0] # GMT projection string (-J)
   raster = opts[1]     # raster to convert to map
   convert = opts[2]    # multiplier to convert map units to inches (m = 39.37, ft = 12.00)
   shade = opts[3]      # optional shaded relief map
   
   # Set up the environment variables
   set_environment()

   # Write out the gmt file header
   fout = open('%s.gmt' % raster, 'w')
   fout.write('# GMT FILE BUILT BY r.out.gmt.py\n\n')
   fout.write('gmtdefaults -D > .gmtdefaults4\n')
   fout.write('gmtset PLOT_DEGREE_FORMAT ddd:mm:ssF OBLIQUE_ANNOTATION 34\n')   
   
   # Build a copy the size of the current region
   os.system('r.mapcalc "temp = %s"' % raster)
   os.system('r.colors map=temp rast=%s' % raster)
   
   # Shaded relief map?
   if shade != None:
      
      os.system('r.mapcalc "temp2 = (%s / 50) - 1"' % shade)
      os.system('r.colors map=temp2 rast=%s' % shade)

   # Convert to GMT
   grast = GrassRaster('temp')
   grast.gmt_convert(raster)
   grast.gmt_colormap(raster+".cpt")
   
   if shade != None:
      grast2 = GrassRaster('temp2')
      grast2.gmt_convert(shade)
      grast2.gmt_colormap(shade+".cpt")
      
   # Calculate the appropriate scale for the raster
   # In linear projection the raster units are assumed to be the same as
   # the gmt's MEASURE_UNITS. AS a result we do not need to convert from
   # map units to page units
   data_height = grast.rows * grast.nsres
   data_width = grast.cols * grast.ewres
   
   if (data_height >= data_width):
      orientation = "-P"
      scale = data_height / MAX_DIMENSION
   else:
      orientation = ""
      scale = data_width / MAX_DIMENSION

   # Calculate the appropriate scale for psbasemap
   # and find a nice annotation interval
   #
   # NOW we need to convert from map units to page units
   # to get the scale right so we use the convert multiplier
   # to convert from map units to page units (inches)
   if (data_height >= data_width):
      geoscale =  data_height / MAX_DIMENSION * float(convert)
   else:
      geoscale = data_width / MAX_DIMENSION * float(convert)
      
   # Calculate a nice annotation interval
   yrange = abs(grast.latur - grast.latll)
   xrange = abs(grast.lonur - grast.lonll)
   brange = min(yrange, xrange)
   if brange > 10:
      bsize = "10"
   elif brange > 5:
      bsize = "1"
   elif brange > 2:
      bsize = "30m"
   elif brange > 1:
      bsize = "15m"
   elif brange > 0.5:
      bsize = "10m"
   elif brange > 0.25:
      bsize = "5m"
   elif brange > 0.1:
      bsize = "2m"
   else:
      bsize = "1m"
      
   # Calculate a nice range interval from the original raster
   # since the colormap uses the original range not the truncated ones
   # in temp
   info = os.popen('r.info -r map=%s' % raster)
   zmin = float(info.readline().split('=')[1])
   zmax = float(info.readline().split('=')[1])
   zsize = (zmax - zmin) / 5
   
   # Scale latitude
   scalelat = grast.latll + (grast.latur - grast.latll)/2.
   
   # Scale length
   scalelen = 5
   
   # Projection string
   geoproj = "%s/1:%f" % (projection, geoscale)
   
   # Build a nice map
   if shade != None:
      fout.write("grdimage %s.grd -I%s.grd -Jx1:%f %s -C%s.cpt %s -Y2i -K > %s.ps\n" % (raster, shade, scale, grast.gmt_region(), raster, orientation, raster))   
   else:
      fout.write("grdimage %s.grd -Jx1:%f %s -C%s.cpt %s -Y2i -K > %s.ps\n" % (raster, scale, grast.gmt_region(), raster, orientation, raster))
   
   fout.write("psbasemap %s %s -B%s -Tx0.5/0.5/0.5i:: -Lx4.5/0.5/%f/%f -O -K %s >> %s.ps\n" % (geoproj, grast.gmt_region_ll(), bsize, scalelat, scalelen, orientation, raster))
   fout.write("psscale -D2i/-0.5i/3i/0.25ih -B%f:Value:/:units: -C%s.cpt -I -O %s >> %s.ps\n" % (zsize, raster, orientation, raster))
   fout.write("\n")
   fout.write("# Uncomment the following line to convert the image into png format\n")
   fout.write("# (Requires imagemagick):\n")
   fout.write("# convert %s.ps %s.png\n" % (raster, raster))
   fout.close()

   # Execute the map
   os.system('chmod +x %s.gmt' % raster)
   #print "Sleeping for 2 seconds..."
   #os.system('sleep 2')
   os.system('%s.gmt' % raster)
   
   print
   print "GMT Plot file %s.gmt has been created" % raster
   print "along with supporting grd and cpt files."
   print
   print "Consider hand editing the plot file for fine-tuning."
   print
if __name__ == "__main__":
   main()

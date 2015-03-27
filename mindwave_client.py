
#
#  every time a reading comes in from the mindwave device,
#  this script sends a json object of all that data to localhost:4228
#
# (c) 2014 ffff (http://cosmopol.is) 
# MIT license 


from mindwave_mobile import ThinkGearProtocol, ThinkGearRawWaveData, ThinkGearEEGPowerData, ThinkGearPoorSignalData, ThinkGearAttentionData, ThinkGearMeditationData
import sys
import platform
import requests
import json

class Client():

    def __init__(self, server_url):
        self.server_url = server_url 
        self.username = None
        self.buffer_size = 512 
        self.raw_log = []
        self.attention_esense= None
        self.meditation_esense= None 
        self.eeg_power= None 
        self.signal_quality = 0
        self.start_time = None
        self.end_time = None
        self.port = '/dev/tty.MindWaveMobile-DevA'

    def make_object(self):
        # construct json
        return {'username':self.username,
            'signal_quality':self.signal_quality,
            'raw_values':self.raw_log, 
            'attention_esense':self.attention_esense,
            'meditation_esense':self.meditation_esense,
            'eeg_power':self.eeg_power
        }

    def post_data(self):
        requests.post(
            self.server_url,
            data=json.dumps(self.make_object()),
            headers={'content-type': 'application/json', 'Accept': 'text/plain'}
        )

    def run(self):

        # get port
        if 'Windows' in platform.system():
            port_number = raw_input('Windows OS detected. Please select proper COM part number:')
            port= "COM%s"%port_number if len(port_number)>0 else "COM%5"

        print 'starting communication with device...'

        for pkt in ThinkGearProtocol(self.port).get_packets():

            for d in pkt:

                if isinstance(d, ThinkGearPoorSignalData):
                    self.signal_quality += int(str(d))
                    
                if isinstance(d, ThinkGearAttentionData):
                    self.attention_esense = int(str(d))

                if isinstance(d, ThinkGearMeditationData):
                    self.meditation_esense = int(str(d))

                if isinstance(d, ThinkGearEEGPowerData):
                    # this cast is both amazing and embarrassing
                    self.eeg_power = eval(str(d).replace('(','[').replace(')',']'))

                if isinstance(d, ThinkGearRawWaveData): 
                    # record a reading
                    # how/can/should we cast this data beforehand?
                    self.raw_log.append(float(str(d))) 

                    # the data is all shipped here
                    if len(self.raw_log) == self.buffer_size:
                        self.post_data()
                        # reset variables
                        self.raw_log = []
                        self.signal_quality = 0


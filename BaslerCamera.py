# Doc (have fun lol)
#   InstantCamera: https://docs.baslerweb.com/pylonapi/cpp/class_pylon_1_1_c_basler_universal_instant_camera
#   GrabResult: https://docs.baslerweb.com/pylonapi/cpp/class_pylon_1_1_c_basler_universal_grab_result_data

from pypylon import pylon


class BaslerCamera:
    def __init__(self):
        self.camera = pylon.InstantCamera(pylon.TlFactory.GetInstance().CreateFirstDevice())
        
        # Internal
        self._isRunning = False

    def __del__(self):
        self.stop()

    def start(self, pxFormat='Mono8'):
        self._isRunning = True
        self.camera.Open()

        #************************************
        # Camera Settings (method 1): load preset and edit in code
        #******************
        # Load camera settings
        #   https://docs.baslerweb.com/user-sets
        self.camera.UserSetSelector = "Default"
        #self.camera.UserSetSelector = "AutoFunctions"
        self.camera.UserSetLoad.Execute()
        
        self.camera.PixelFormat = pxFormat
        #self.camera.PixelFormat = 'Mono8'
        #self.camera.PixelFormat = 'RGB8'
        #self.camera.PixelFormat = 'BGR8' # For opencv
        
        #************************************
        # Camera Settings (method 2): save/load settings file
        #******************
        # Export settings
        #pylon.FeaturePersistence.Save("tmp.pfs", self.camera.GetNodeMap())
        #self.camera.Close()
        #sys.exit(0)
        
        # Load camera settings
        # To generate this file
        #   Power cycle the camera to restore settings to default (unplug, then re-plugin the usb cable)
        #   pylon viewer:
        #       Open camera
        #       Edit camera 'Features' as desired
        #       pylon viewer > Camera > Save Features
        #   or uncomment above "Export settings"
        #nodeFile = "config/Default_Mono8.pfs"
        #pylon.FeaturePersistence.Load(nodeFile, self.camera.GetNodeMap(), True)

    def stop(self):
        self._isRunning = False
        self.camera.Close()
        
    # Get frame - trigger camera to take an image
    # OUTPUT: uint8 numpy array of image
    def GetFrame(self):
        try:
            grabResult = self.camera.GrabOne(100)
            if grabResult.GrabSucceeded():
                return grabResult.Array
        except:
            pass
        raise Exception("ErrorRetrievingFrame")

//
//  rtc.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 8/5/2023.
//

import Foundation
import WebRTC

extension RTCIceConnectionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .new:          return "new"
        case .checking:     return "checking"
        case .connected:    return "connected"
        case .completed:    return "completed"
        case .failed:       return "failed"
        case .disconnected: return "disconnected"
        case .closed:       return "closed"
        case .count:        return "count"
        @unknown default:   return "Unknown \(self.rawValue)"
        }
    }
}

protocol WebRTCClientDelegate: class {
    func webRTCClient(_ client: WebRTCClient, sendData data: Data)
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didReceivedRemoteStream stream: RTCMediaStream)
    
    func webRTCClient(_ client: WebRTCClient, didChangeIceConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCPeerConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

class WebRTCClient : NSObject {
    //RTC peer factory
    static let factory : RTCPeerConnectionFactory = {
        RTCInitializeSSL() //init ssl
        let vef = RTCDefaultVideoEncoderFactory()
        let vdf = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: vef, decoderFactory: vdf)
    }()
    
    //Variable
    
    //how many candinate is connected
    private var candidateQueue = [RTCIceCandidate]()
    private let audioQueue = DispatchQueue(label: "audio")
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    
    weak var delegate: WebRTCClientDelegate?
    private var hasReceivedSPD = false
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveVideo:kRTCMediaConstraintsValueTrue,kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue]
    
    private var peerConn : RTCPeerConnection?
    private var localVideoSource : RTCVideoSource?
    var localVideoTrack : RTCVideoTrack?
    var localAudioTrack : RTCAudioTrack?
    var remoteVIdeoTrack : RTCVideoTrack?
    var remoteAudioTrack : RTCAudioTrack?
    var videoCapture : RTCVideoCapturer?
    
    private var hsaReceivedSDP = false
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?

    
    override init(){
        super.init()
    }
    
    func disconnectRTCConnection(){
        self.peerConn?.close()
        
    }

    func setUp(isProducer : Bool = true){
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement" : "true"])
        let config = genConfig()
        self.peerConn = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: self)
        guard let peerConn = peerConn else {
            print("Peer connection set Up error")
            return
        }
        createMedia(isProducer: isProducer)
    }
    
    func createMedia(isProducer : Bool){
        if isProducer{
            createMedia()
        }else {
            createMediaAsConsumer()
        }
    }
    
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void){
        guard let peerConn = self.peerConn else {
            print("Peer connection have't created.")
            return
        }
        
        if hasReceivedSPD {
            return
        }
        
        peerConn.offer(for: RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)){ [weak self] (sdp,error) in
            
            guard let self = self else {return}
            
            guard let sdp = sdp else {
                if let err = error {
                    print(err)
                }
                return
            }
            
            //MARK: set local sdp for sender.
//            print(sdp)
            peerConn.setLocalDescription(sdp) { err in
               completion(sdp)
            }
            
        }
    }
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void){
        guard let peerConn = peerConn else {
            print("Peer connection have't created.")
            return
        }
        
        print("WebRTC answers.")
        
        peerConn.answer(for: RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)) { [weak self] (sdp,error) in
            guard let self = self else {
                return
            }
            
            guard let sdp = sdp else {
                if let err = error {
                    print(err)
                }
                
                return
            }
            
            //MARK: Set local SDP for recever
            peerConn.setLocalDescription(sdp) { err in
               completion(sdp)
            }
        }
    }
    
//    private func setLocalSDP(_ sdp : RTCSessionDescription,type : CallingType) {
//        guard let peerConn = peerConn else {
//            print("Peer connection have't created.")
//            return
//        }
//
//        peerConn.setLocalDescription(sdp) { err in
//            if let err = err {
//                print(err)
//                return
//            }
//        }
//        
//        
//        if let data = sdp.JSONData(type: type) {
//            self.delegate?.webRTCClient(self, sendData: data) //TODO: define in RTCViewModel
//            print("sent local SDP")
//        }
//
//    }
    
    private func setCandindate(remoteCandidate : RTCIceCandidate){
        guard let peerConn = peerConn else {
            print("Peer connection have't created.")
            return
        }
        
        peerConn.add(remoteCandidate){err in
            print("set remote candidate failed")
        }
    }
    
    func disconnect(){
        peerConn?.close()
        
        peerConn = nil
        localVideoTrack = nil
        localAudioTrack = nil
        videoCapture = nil
        remoteVIdeoTrack = nil
        remoteAudioTrack = nil
    }
    
    //MARK: set video to true/false or check video is enable
    var VideoIsEnable : Bool {
        get {
            if localVideoTrack == nil {
                return false
            }
            return localVideoTrack!.isEnabled
        }set {
            localVideoTrack?.isEnabled = newValue
        }
    }
    
    //MARK: set audio to true/false or check audio is enable
    var AudioIsEnable : Bool {
        get {
            if localAudioTrack == nil {
                return false
            }
            return localAudioTrack!.isEnabled
        }set {
            localAudioTrack?.isEnabled = newValue
        }
    }

}

extension WebRTCClient {
    //TODO: IceServer and signleServer config to gen RTC config
    private func genConfig() -> RTCConfiguration {
        let config = RTCConfiguration()
        //MARK: do we need SSL?
//        let cert = RTCCertificate.generate(withParams:  ["expires": NSNumber(value: 100000),"name": "RSASSA-PKCS1-v1_5"])
        config.iceServers = [RTCIceServer(urlStrings: Config.default.IceServers)]
        config.sdpSemantics = RTCSdpSemantics.unifiedPlan //sdp plan
//        config.certificate = cert
        return config
    }
    
    private func createMedia() {
        guard let peerConn = peerConn else {
            print("peer connection haven't created.")
            return
        }
        let streamID = "stream"
        //put the source to peer connection and send
        let audioTrack = createAutioTrack()
        self.localAudioTrack = audioTrack
        peerConn.add(audioTrack, streamIds: [streamID])
        
        let videoTrack = createVideoTrack()
        self.localVideoTrack = videoTrack
        peerConn.add(videoTrack, streamIds: [streamID])
        
//        remoteVIdeoTrack = peerConn.transceivers.first {$0.mediaType == .video}?.receiver.track as? RTCVideoTrack
        
        //TODO: Data channel for data only?
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }else{
            print("Create data channel failed")
        }
    }
    
    
    
    private func createMediaAsConsumer() {
        guard let peerConn = peerConn else {
            print("peer connection haven't created.")
            return
        }
        remoteVIdeoTrack = peerConn.transceivers.first {$0.mediaType == .video}?.receiver.track as? RTCVideoTrack
        //TODO: Data channel for data only?
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
    }
    
    private func createVideoTrack() -> RTCVideoTrack{
        let source = WebRTCClient.factory.videoSource()
//        self.videoCapture = RTCCameraVideoCapturer(delegate: source)
        #if targetEnvironment(simulator)
        self.videoCapture = RTCFileVideoCapturer(delegate: source)
        #else
        self.videoCapture = RTCCameraVideoCapturer(delegate: source)
        #endif
//        
        let track = WebRTCClient.factory.videoTrack(with: source, trackId: "video0")
        return track
    }
    
    private func createAutioTrack() -> RTCAudioTrack{
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let source = WebRTCClient.factory.audioSource(with: audioConstrains)
        let track = WebRTCClient.factory.audioTrack(with: source, trackId: "audio0")
        return track
    }
    
    private func createDataChannel() -> RTCDataChannel? {
        guard let peerConn = self.peerConn else {
            debugPrint("Peer connection is nil")
            return nil
        }
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = peerConn.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            debugPrint("Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        print(self.remoteDataChannel  == nil)
        self.remoteDataChannel?.sendData(buffer)
    }
    
    func startCapture(renderer: RTCVideoRenderer){
        guard let capturer = self.videoCapture as? RTCCameraVideoCapturer else {
            return
        }
    
        guard let (camera,format,fps) = backCamera() else {
            return
        }
        
        capturer.startCapture(with: camera,
                              format: format,
                              fps: Int(fps.maxFrameRate))
        self.localVideoTrack?.add(renderer)
    }
    
    func stopCature() -> Bool {
        guard let capturer = self.videoCapture as? RTCCameraVideoCapturer else {
            return false
        }
        capturer.stopCapture()
        return true
    }
    
    func changeCamera(possion : CameraPossion) {
        guard let capturer = self.videoCapture as? RTCCameraVideoCapturer else {
            return
        }
        
        if possion == .front {
            guard let (camera,format,fps) = frontCamera() else {
                return
            }
            
            capturer.startCapture(with: camera,
                                  format: format,
                                  fps: Int(fps.maxFrameRate))
        }else {
            guard let (camera,format,fps) = frontCamera() else {
                return
            }
            
            capturer.startCapture(with: camera,
                                  format: format,
                                  fps: Int(fps.maxFrameRate))
        }
        
        debugPrint("done")
    }
    
    private func frontCamera() -> (AVCaptureDevice,AVCaptureDevice.Format,AVFrameRateRange)? {
        guard
            let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }),
            
                // choose highest res
            let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }).last,
            
                // choose highest fps
            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
            return nil
        }
        
        return (frontCamera,format,fps)
    }
    
    private func backCamera() -> (AVCaptureDevice,AVCaptureDevice.Format,AVFrameRateRange)? {
        guard
            let backCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .back }),
            
                // choose highest res
            let format = (RTCCameraVideoCapturer.supportedFormats(for: backCamera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }).last,
            
                // choose highest fps
            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
            return nil
        }
        
        return (backCamera,format,fps)
    }
    
    func renderRemoteVideo(renderer : RTCVideoRenderer) {
        guard let _ = self.remoteVIdeoTrack else{
            debugPrint("Render video - video track is nil")
            return
        }
        self.remoteVIdeoTrack?.add(renderer)
    }
}

extension WebRTCClient {
    func handleCandidateMessage(_ candidate: RTCIceCandidate,completion: @escaping (Error?) -> ()) {
//        print("add candindate to peer connection")
        
        self.peerConn?.add(candidate, completionHandler: completion)
    }
    
    func handleRemoteDescription(_ desc: RTCSessionDescription,completion: @escaping (Error?) -> ()) {
        guard let peerConnection = self.peerConn else {
            return
        }
        
        hasReceivedSPD = true
        
        peerConnection.setRemoteDescription(desc,completionHandler: completion)
    }
    
//    func handleRemoteCandindates(_ candindate: RTCIceCandidate) {
//        //candindate ->
//        guard let peerConn = self.peerConn ,hasReceivedSPD else {
//            return
//        }channel
//
//        peerConn.add(candindate){ err in
//            if err != nil {
//                print("add candindate failed : \(err!.localizedDescription)")
//            }
//            
//        }
//    }
}


//MARK: implmented RTCPeerConnectionDelegate - NOT DONE YET
extension WebRTCClient : RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream to connection..........")
        debugPrint(stream.streamId)
        debugPrint("audio tracks \(stream.audioTracks.count)")
        debugPrint("video tracks \(stream.videoTracks.count)")
        if let track = stream.videoTracks.first {
              print("video track faund")
             remoteVIdeoTrack = peerConnection.transceivers.first {$0.mediaType == .video}?.receiver.track as? RTCVideoTrack
            self.remoteVIdeoTrack = track
          }
          
          if let audioTrack = stream.audioTracks.first{
              print("audio track faund")
//              audioTrack.source.volume = 8
          }
//        remoteVIdeoTrack = self.peerConn?.transceivers.first {$0.mediaType == .video}?.receiver.track as? RTCVideoTrack
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCPeerConnectionState) {
        debugPrint("peerConnection new  connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new ice connection state: \(newState)")
//        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
        self.delegate?.webRTCClient(self, didChangeIceConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("didOpen Data Channel ----- Can send the message via data channel")
        self.remoteDataChannel = dataChannel
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        print("Received message")
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}

extension WebRTCClient {
    func mute(){
        self.setAudioEnable(false)
    }
    
    func unmute(){
        self.setAudioEnable(true)
    }
    
    func speakerOn(){
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory( AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue))
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let err {
                debugPrint("Error setting AVAAudioSession \(err)")
            }
            self.rtcAudioSession.unlockForConfiguration()
            
        }
    }
    
    func speakerOff(){
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            
            do {
                
                try self.rtcAudioSession.setCategory( AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue))
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let err {
                debugPrint("Error setting AVAAudioSession \(err)")
            }
            self.rtcAudioSession.unlockForConfiguration()
            
        }
    }
    
    private func setAudioEnable(_ isEnable : Bool){
        guard let peerConn = self.peerConn else {
            debugPrint("Peerconnection is not init.")
            return
        }
        
        let audioTrack = peerConn.transceivers.compactMap { return $0.sender.track as? RTCAudioTrack}
        audioTrack.forEach { $0.isEnabled = isEnable}
    }
}

extension WebRTCClient {
    func showVideo(){
        self.setVideoEnable(true)
    }
    
    func hideVideo(){
        self.setVideoEnable(false)
    }
    
    
    
    private func setVideoEnable(_ isEnable : Bool){
        guard let peerConn = self.peerConn else {
            debugPrint("Peerconnection is not init.")
            return
        }
        
        let videoTrack = peerConn.transceivers.compactMap { return $0.sender.track as? RTCVideoTrack}
        videoTrack.forEach { $0.isEnabled = isEnable}
    }
}


extension RTCSessionDescription {
    func JSONData(type : CallingType) -> Data? {
        let typeStr = RTCSessionDescription.string(for: self.type)
        let dict = ["type": typeStr,
                    "call" : type.rawValue.description,
                    "sdp": self.sdp]
        //callType : 0 -> Voice , 1 -> Vedio
        return dict.JSONData
    }
}


extension Dictionary {
    var JSONData: Data? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }
        return data
    }
}

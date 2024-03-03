//
//  multipleRTC.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 25/11/2023.
//
//
//import Foundation
//import WebRTC
//
//
////Create offer -> send to server -> connecte with server RTC
////If someone is joined , send the SDP to client A and set the tracker(queue or list)
//
//protocol MutipleWebRTCClientDelegate: class {
//    func webRTCClient(_ client: MutilpleWebRTCClient, sendData data: Data)
//    func webRTCClient(_ client: MutilpleWebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
////    func webRTCClient(_ client: WebRTCClient, didReceivedRemoteStream stream: RTCVideoTrack)
//    
//    func webRTCClient(_ client: MutilpleWebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
//    func webRTCClient(_ client: MutilpleWebRTCClient, didReceiveData data: Data)
//}
//enum Role {
//    case publisher
//    case subscriber
//}
//
//struct SessionDescription {}
//
//struct ICECandidate {
//    let candidate: String
//    let sdpMid: String
//    let sdpMLineIndex: Int
//    let usernameFragment: String
//}
//
//struct Trickle {
//    let target: Role
//    let candidate: ICECandidate
//}
//
//
//protocol SignalDelegate: AnyObject {
//    func signal(_ signal: Signal, didReceiveTrickle trickle: Trickle)
//    func signal(_ signal: Signal, didReceiveDescription description: SessionDescription)
////    func signal(_ signal: Signal, didReceiveJoinReply join: JoinReply)
////    func signal(_ signal: Signal, failedWithError error: Error)
//}
//
//protocol Signal {
//    var delegate: SignalDelegate { get set }
//
//    func join(session: String, description: SessionDescription)
//    func offer(_ description: SessionDescription)
//    func answer(_ description: SessionDescription)
//    func trickle(_ trickle: Trickle)
//    func close()
//}
//
//
//class MutipleWebRTCSignal : Signal {
//    
//    
//     init(){
//    
//    }
//    
//    
//    var delegate: SignalDelegate
//    
//    func join(session: String, description: SessionDescription) {
//        <#code#>
//    }
//    
//    func offer(_ description: SessionDescription) {
//        <#code#>
//    }
//    
//    func answer(_ description: SessionDescription) {
//        <#code#>
//    }
//    
//    func trickle(_ trickle: Trickle) {
//        <#code#>
//    }
//    
//    func close() {
//        <#code#>
//    }
//    
//    
//}
//
//
//class MutilpleWebRTCClient : NSObject {
//    //RTC peer factory
//    static let factory : RTCPeerConnectionFactory = {
//        RTCInitializeSSL() //init ssl
//        let vef = RTCDefaultVideoEncoderFactory()
//        let vdf = RTCDefaultVideoDecoderFactory()
//        return RTCPeerConnectionFactory(encoderFactory: vef, decoderFactory: vdf)
//    }()
//    
//    //Variable
//    
//    //how many candinate is connected
//    private var candidateQueue = [RTCIceCandidate]()
//    private let audioQueue = DispatchQueue(label: "audio")
//    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
//    
//    weak var delegate: MutipleWebRTCClientDelegate?
//    private var hasReceivedSPD = false
//    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveVideo:kRTCMediaConstraintsValueTrue,kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue]
//    
//    private var peerConn : RTCPeerConnection?
//    private var localVideoSource : RTCVideoSource?
//    var localVideoTrack : RTCVideoTrack?
//    var localAudioTrack : RTCAudioTrack?
////    var remoteVIdeoTrack : RTCVideoTrack?
//    var remoteVIdeoTrackList : Array<RTCVideoTrack>?
//    var videoCapture : RTCVideoCapturer?
//    
//    private var hsaReceivedSDP = false
//    private var localDataChannel: RTCDataChannel?
////    private var remoteDataChannel: RTCDataChannel?
//    private var remoteDataChannelList : Array<RTCDataChannel>?
//
//    
//    override init(){
//        super.init()
//        setUp()
//    }
//    
//    func Disconnect(){
//        self.peerConn?.close()
//        
//    }
//
//    func setUp(){
//        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement" : "true"])
//        let config = genConfig()
//        self.peerConn = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: self)
//        
//        createMedia()
//        
//        ion.Client(signal: MutipleWebRTCSignal(), iceServers: [
//        ])
//    }
//    
//    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void){
//        guard let peerConn = peerConn else {
//            print("Peer connection have't created.")
//            return
//        }
//        if hasReceivedSPD {
//            return
//        }
//        
//        peerConn.offer(for: RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)){ [weak self] (sdp,error) in
//            
//            guard let self = self else {return}
//            
//            guard let sdp = sdp else {
//                if let err = error {
//                    print(err)
//                }
//                return
//            }
//            
//            //MARK: set local sdp for sender.
////            print(sdp)
//            peerConn.setLocalDescription(sdp) { err in
//               completion(sdp)
//            }
//            
//        }
//    }
//    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void){
//        guard let peerConn = peerConn else {
//            print("Peer connection have't created.")
//            return
//        }
//        
//        print("WebRTC answers.")
//        
//        peerConn.answer(for: RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)) { [weak self] (sdp,error) in
//            guard let self = self else {
//                return
//            }
//            
//            guard let sdp = sdp else {
//                if let err = error {
//                    print(err)
//                }
//                
//                return
//            }
//            
//            //MARK: Set local SDP for recever
//            peerConn.setLocalDescription(sdp) { err in
//               completion(sdp)
//            }
//        }
//    }
//    
////    private func setLocalSDP(_ sdp : RTCSessionDescription,type : CallingType) {
////        guard let peerConn = peerConn else {
////            print("Peer connection have't created.")
////            return
////        }
////
////        peerConn.setLocalDescription(sdp) { err in
////            if let err = err {
////                print(err)
////                return
////            }
////        }
////
////
////        if let data = sdp.JSONData(type: type) {
////            self.delegate?.webRTCClient(self, sendData: data) //TODO: define in RTCViewModel
////            print("sent local SDP")
////        }
////
////    }
//    
//    private func setCandindate(remoteCandidate : RTCIceCandidate){
//        guard let peerConn = peerConn else {
//            print("Peer connection have't created.")
//            return
//        }
//        
//        peerConn.add(remoteCandidate){err in
//            print("set remote candidate failed")
//        }
//    }
//    
//    func disconnect(){
//        peerConn?.close()
//        
//        peerConn = nil
//        localVideoTrack = nil
//        localAudioTrack = nil
//        videoCapture = nil
////        remoteVIdeoTrack = nil
//        remoteVIdeoTrackList = nil
//    }
//    
//    //MARK: set video to true/false or check video is enable
//    var VideoIsEnable : Bool {
//        get {
//            if localVideoTrack == nil {
//                return false
//            }
//            return localVideoTrack!.isEnabled
//        }set {
//            localVideoTrack?.isEnabled = newValue
//        }
//    }
//    
//    //MARK: set audio to true/false or check audio is enable
//    var AudioIsEnable : Bool {
//        get {
//            if localAudioTrack == nil {
//                return false
//            }
//            return localAudioTrack!.isEnabled
//        }set {
//            localAudioTrack?.isEnabled = newValue
//        }
//    }
//
//}
//
//extension MutilpleWebRTCClient {
//    //TODO: IceServer and signleServer config to gen RTC config
//    private func genConfig() -> RTCConfiguration {
//        let config = RTCConfiguration()
//        //MARK: do we need SSL?
//        let cert = RTCCertificate.generate(withParams:  ["expires": NSNumber(value: 100000),"name": "RSASSA-PKCS1-v1_5"])
//        config.iceServers = [RTCIceServer(urlStrings: Config.default.IceServers)]
//        config.sdpSemantics = RTCSdpSemantics.unifiedPlan //sdp plan
//        config.certificate = cert
//        return config
//    }
//    
//    private func createMedia() {
//        guard let peerConn = peerConn else {
//            print("peer connection haven't created.")
//            return
//        }
//        
//        let streamID = "stream"
//        //put the source to peer connection and send
//        let audioTrack = createAutioTrack()
//        self.localAudioTrack = audioTrack
//        peerConn.add(audioTrack, streamIds: [streamID])
//        
//        let videoTrack = createVideoTrack()
//        self.localVideoTrack = videoTrack
//        peerConn.add(videoTrack, streamIds: [streamID])
//        
////        remoteVIdeoTrack = peerConn.transceivers.first {$0.mediaType == .video}?.receiver.track as? RTCVideoTrack
//        
//        //TODO: Data channel for data only?
//        if let dataChannel = createDataChannel() {
//            dataChannel.delegate = self
//            self.localDataChannel = dataChannel
//        }
//    }
//    
//    private func createVideoTrack() -> RTCVideoTrack{
//        let source = WebRTCClient.factory.videoSource()
//
//        #if targetEnvironment(simulator)
//        self.videoCapture = RTCFileVideoCapturer(delegate: source)
//        #else
//        self.videoCapture = RTCCameraVideoCapturer(delegate: source)
//        #endif
//        
//        let track = WebRTCClient.factory.videoTrack(with: source, trackId: "video0")
//        return track
//    }
//    private func createAutioTrack() -> RTCAudioTrack{
//        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
//        let source = WebRTCClient.factory.audioSource(with: audioConstrains)
//        let track = WebRTCClient.factory.audioTrack(with: source, trackId: "audio0")
//        return track
//    }
//    
//    private func createDataChannel() -> RTCDataChannel? {
//        guard let peerConn = self.peerConn else {
//            debugPrint("Peer connection is nil")
//            return nil
//        }
//        let config = RTCDataChannelConfiguration()
//        guard let dataChannel = peerConn.dataChannel(forLabel: "WebRTCData", configuration: config) else {
//            debugPrint("Couldn't create data channel.")
//            return nil
//        }
//        return dataChannel
//    }
//    
//    func sendData(_ data: Data) {
//        let buffer = RTCDataBuffer(data: data, isBinary: true)
////        self.remoteDataChannel?.sendData(buffer)
//    }
//    
//    func startCapture(renderer: RTCVideoRenderer){
//        guard let capturer = self.videoCapture as? RTCCameraVideoCapturer else {
//            return
//        }
//    
//        guard let (camera,format,fps) = frontCamera() else {
//            return
//        }
//        
//        capturer.startCapture(with: camera,
//                              format: format,
//                              fps: Int(fps.maxFrameRate))
//        self.localVideoTrack?.add(renderer)
//    }
//    
//    func stopCature() -> Bool {
//        guard let capturer = self.videoCapture as? RTCCameraVideoCapturer else {
//            return false
//        }
//        capturer.stopCapture()
//        return true
//    }
//    
//    func changeCamera(possion : CameraPossion) {
//        guard let capturer = self.videoCapture as? RTCCameraVideoCapturer else {
//            return
//        }
//        
//        if possion == .front {
//            guard let (camera,format,fps) = frontCamera() else {
//                return
//            }
//            
//            capturer.startCapture(with: camera,
//                                  format: format,
//                                  fps: Int(fps.maxFrameRate))
//        }else {
//            guard let (camera,format,fps) = backCamera() else {
//                return
//            }
//            
//            capturer.startCapture(with: camera,
//                                  format: format,
//                                  fps: Int(fps.maxFrameRate))
//        }
//        
//        debugPrint("done")
//    }
//    
//    private func frontCamera() -> (AVCaptureDevice,AVCaptureDevice.Format,AVFrameRateRange)? {
//        guard
//            let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }),
//            
//                // choose highest res
//            let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
//                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
//                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
//                return width1 < width2
//            }).last,
//            
//                // choose highest fps
//            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
//            return nil
//        }
//        
//        return (frontCamera,format,fps)
//    }
//    
//    private func backCamera() -> (AVCaptureDevice,AVCaptureDevice.Format,AVFrameRateRange)? {
//        guard
//            let backCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .back }),
//            
//                // choose highest res
//            let format = (RTCCameraVideoCapturer.supportedFormats(for: backCamera).sorted { (f1, f2) -> Bool in
//                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
//                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
//                return width1 < width2
//            }).last,
//            
//                // choose highest fps
//            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
//            return nil
//        }
//        
//        return (backCamera,format,fps)
//    }
//    
//    func renderRemoteVideo(renderer : RTCVideoRenderer) {
////        self.remoteVIdeoTrack?.add(renderer)
//    }
//}
//
//extension MutilpleWebRTCClient {
//    func handleCandidateMessage(_ candidate: RTCIceCandidate,completion: @escaping (Error?) -> ()) {
////        print("add candindate to peer connection")
//        self.peerConn?.add(candidate, completionHandler: completion)
//    }
//    
//    func handleRemoteDescription(_ desc: RTCSessionDescription,completion: @escaping (Error?) -> ()) {
//        guard let peerConnection = self.peerConn else {
//            return
//        }
//        
//        hasReceivedSPD = true
//        
//        peerConnection.setRemoteDescription(desc,completionHandler: completion)
//    }
//    
//    func handleRemoteCandindates(_ candindate: RTCIceCandidate) {
//        //candindate ->
//        guard let peerConn = self.peerConn ,hasReceivedSPD else {
//            return
//        }
//         
//        peerConn.add(candindate){ err in
//            if err != nil {
//                print("add candindate failed : \(err!.localizedDescription)")
//            }
//            
//        }
//    }
//}
//
//
////MARK: implmented RTCPeerConnectionDelegate - NOT DONE YET
//extension MutilpleWebRTCClient : RTCPeerConnectionDelegate {
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
//        debugPrint("peerConnection new signaling state: \(stateChanged)")
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
//        debugPrint("peerConnection did add stream")
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
//        debugPrint("peerConnection did remove stream")
//    }
//    
//    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
//        debugPrint("peerConnection should negotiate")
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
//        debugPrint("peerConnection new connection state: \(newState)")
//        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
//        debugPrint("peerConnection new gathering state: \(newState)")
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
//        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
//        debugPrint("peerConnection did remove candidate(s)")
//    }
//    
//    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
//        print("didOpen Data Channel")
////        self.remoteDataChannel = dataChannel
//    }
//}
//
//extension MutilpleWebRTCClient: RTCDataChannelDelegate {
//    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
//        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
//    }
//    
//    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
//        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
//    }
//}
//
//extension MutilpleWebRTCClient {
//    func mute(){
//        self.setAudioEnable(false)
//    }
//    
//    func unmute(){
//        self.setAudioEnable(true)
//    }
//    
//    func speakerOn(){
//        self.audioQueue.async { [weak self] in
//            guard let self = self else {
//                return
//            }
//            self.rtcAudioSession.lockForConfiguration()
//            do {
//                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
//                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
//                try self.rtcAudioSession.setActive(true)
//            } catch let err {
//                debugPrint("Error setting AVAAudioSession \(err)")
//            }
//            self.rtcAudioSession.unlockForConfiguration()
//            
//        }
//    }
//    
//    func speakerOff(){
//        self.audioQueue.async { [weak self] in
//            guard let self = self else {
//                return
//            }
//            self.rtcAudioSession.lockForConfiguration()
//            do {
//                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
//                try self.rtcAudioSession.overrideOutputAudioPort(.none)
//            } catch let err {
//                debugPrint("Error setting AVAAudioSession \(err)")
//            }
//            self.rtcAudioSession.unlockForConfiguration()
//            
//        }
//    }
//    
//    private func setAudioEnable(_ isEnable : Bool){
//        guard let peerConn = self.peerConn else {
//            debugPrint("Peerconnection is not init.")
//            return
//        }
//        
//        let audioTrack = peerConn.transceivers.compactMap { return $0.sender.track as? RTCAudioTrack}
//        audioTrack.forEach { $0.isEnabled = isEnable}
//    }
//}
//
//extension MutilpleWebRTCClient {
//    func showVideo(){
//        self.setVideoEnable(true)
//    }
//    
//    func hideVideo(){
//        self.setVideoEnable(false)
//    }
//    
//    
//    
//    private func setVideoEnable(_ isEnable : Bool){
//        guard let peerConn = self.peerConn else {
//            debugPrint("Peerconnection is not init.")
//            return
//        }
//        
//        let videoTrack = peerConn.transceivers.compactMap { return $0.sender.track as? RTCVideoTrack}
//        videoTrack.forEach { $0.isEnabled = isEnable}
//    }
//}

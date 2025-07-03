//
//  TrackUniversalLinkSpec.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 07/06/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

import CoreData
import Foundation
import Nimble
import Quick
import Mockingjay

@testable import SendsaySDK

class TrackUniversalLinkSpec: QuickSpec {
    override func spec() {
        let mockData = MockData()

        describe("Track universal link") {
            context("repository") {
                let repository = ServerRepository(configuration: try! Configuration(plistName: "SendsayConfig"))
                let projectToken = UUID().uuidString
                let data: [DataType] = [
                    .properties(mockData.campaignData),
                    .timestamp(nil),
                    .eventType(Constants.EventTypes.campaignClick)
                ]
                var lastRequest: URLRequest?
                NetworkStubbing.stubNetwork(
                    forProjectToken: projectToken,
                    withStatusCode: 200,
                    withRequestHook: { request in lastRequest = request }
                )
                waitUntil(timeout: .seconds(3)) { done in
                    let event = EventTrackingObject(
                        sendsayProject: SendsayProject(
                            baseUrl: "https://my-url.com",
                            projectToken: projectToken,
                            authorization: .none
                        ),
                        customerIds: mockData.customerIds,
                        eventType: Constants.EventTypes.campaignClick,
                        timestamp: 123,
                        dataTypes: data
                    )
                    repository.trackObject(event) { result in
                        it("should have nil result error") {
                            expect(result.error).to(beNil())
                        }
                        it("should call correct url") {
                            expect(lastRequest?.url?.absoluteString)
                                .to(equal("https://my-url.com/track/v2/projects/\(projectToken)/campaigns/clicks"))
                        }
                        it("should contains required properties") {
                            guard let requestBody: String = lastRequest?.httpBodyStream?.readFully() else {
                                fail("Request data are invalid")
                                done()
                                return
                            }
                            expect(requestBody).to(contain("platform"))
                        }
                        done()
                    }
                }
            }
            context("Tracking manager") {
                context("with SDK started") {
                    it("track campaign_click and update session when called within update threshold") {
                        let sendsay = MockSendsayImplementation()
                        sendsay.configure(plistName: "SendsayConfig")

                        // track campaign click, session_start should be updated with utm params
                        sendsay.trackCampaignClick(url: mockData.campaignUrl!, timestamp: nil)

                        let campaignClick = findEvent(sendsay: sendsay, eventType: "campaign_click")
                        expect(campaignClick).notTo(beNil())
                        let sessionStart = findEvent(sendsay: sendsay, eventType: "session_start")
                        expect(sessionStart).notTo(beNil())
                        expect(sessionStart!.dataTypes.properties["utm_campaign"] as? String)
                            .to(equal("mycampaign"))
                    }
                    it("track campaign_click and should not update session when called after update threshold") {
                        let sendsay = MockSendsayImplementation()
                        sendsay.configure(plistName: "SendsayConfig")
                        Sendsay.logger.logLevel = .verbose
                        expect {
                            try sendsay.trackingManager!.updateLastPendingEvent(
                                ofType: Constants.EventTypes.sessionStart,
                                with: .timestamp(
                                    Date().timeIntervalSince1970 - Constants.Session.sessionUpdateThreshold
                                )
                            )
                        }.notTo(raiseException())

                        // track campaign click, session_start should not be updated with utm params
                        sendsay.trackCampaignClick(url: mockData.campaignUrl!, timestamp: nil)

                        let campaignClick = findEvent(sendsay: sendsay, eventType: "campaign_click")
                        expect(campaignClick).notTo(beNil())
                        let sessionStart = findEvent(sendsay: sendsay, eventType: "session_start")
                        expect(sessionStart).toNot(beNil())
                        expect(sessionStart!.dataTypes.properties["utm_campaign"] as? String).to(beNil())
                    }
                    it("not track campaign_click but update session") {
                        let sendsay = MockSendsayImplementation()
                        sendsay.configure(plistName: "SendsayConfig")

                        // track campaign click, session_start should be updated with utm params
                        sendsay.trackCampaignClick(url: mockData.invalidCampaignUrl!, timestamp: nil)

                        let campaignClick = findEvent(sendsay: sendsay, eventType: "campaign_click")
                        expect(campaignClick).to(beNil())
                        let sessionStart = findEvent(sendsay: sendsay, eventType: "session_start")
                        expect(sessionStart).notTo(beNil())
                        expect(sessionStart!.dataTypes.properties["utm_campaign"] as? String).to(equal("mycampaign"))
                    }
                }
                context("before SDK started") {
                    it("track campaign_click and update session when called within update threshold") {
                        let sendsay = MockSendsayImplementation()

                        // track campaign click, session_start should be updated with utm params
                        sendsay.trackCampaignClick(url: mockData.campaignUrl!, timestamp: nil)

                        sendsay.configure(plistName: "SendsayConfig")

                        let campaignClick = findEvent(sendsay: sendsay, eventType: "campaign_click")
                        expect(campaignClick).notTo(beNil())
                        let sessionStart = findEvent(sendsay: sendsay, eventType: "session_start")
                        expect(sessionStart).notTo(beNil())
                        expect(sessionStart!.dataTypes.properties["utm_campaign"] as? String)
                            .to(equal("mycampaign"))
                    }
                    it("processes saved campaigns only once") {
                        let sendsay = MockSendsayImplementation()

                        // track campaign click, session_start should be updated with utm params
                        sendsay.trackCampaignClick(url: mockData.campaignUrl!, timestamp: nil)

                        sendsay.configure(plistName: "SendsayConfig")
                        var trackEvents: [TrackEventProxy] = []
                        expect { trackEvents = try sendsay.fetchTrackEvents() }.toNot(raiseException())
                        expect { trackEvents.filter({ $0.eventType == "campaign_click" }).count }.to(equal(1))
                    }
                    it("not track campaign_click but update session") {
                        let sendsay = MockSendsayImplementation()

                        // track campaign click, session_start should be updated with utm params
                        sendsay.trackCampaignClick(url: mockData.invalidCampaignUrl!, timestamp: nil)

                        sendsay.configure(plistName: "SendsayConfig")

                        let campaignClick = findEvent(sendsay: sendsay, eventType: "campaign_click")
                        expect(campaignClick).to(beNil())
                        let sessionStart = findEvent(sendsay: sendsay, eventType: "session_start")
                        expect(sessionStart).notTo(beNil())
                        expect(sessionStart!.dataTypes.properties["utm_campaign"] as? String).to(equal("mycampaign"))
                    }
                }
            }
        }
    }
}

func findEvent(sendsay: MockSendsayImplementation, eventType: String) -> TrackEventProxy? {
    var trackEvents: [TrackEventProxy] = []
    expect { trackEvents = try sendsay.fetchTrackEvents() }.toNot(raiseException())
    return trackEvents.first(where: { $0.eventType == eventType })
}

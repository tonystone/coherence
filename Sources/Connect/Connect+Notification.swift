///
///  Connect+Notification.swift
///  Pods
///
///  Created by Tony Stone on 2/26/17.
///
///
import Swift

///
/// Connect specific notifications.
///
public extension  Notification {

    ///
    /// Notification sent when an `Action` starts executing.
    ///
    /// - Note: posted to the default `NotificationCenter`. The notification object is the `Connect` instance posting the notification.
    ///
    /// - SeeAlso: `NotificationCenter`
    /// - SeeAlso: `ActionProxy`
    ///
    public static let ActionDidStartExecuting = Foundation.Notification.Name(rawValue: "Coherence.Connect.ActionDidStartExecuting")

    ///
    /// Notification sent when an `Action` finishes executing.
    ///
    /// - Note: posted to the default `NotificationCenter`. The notification object is the `Connect` instance posting the notification.
    ///
    /// - SeeAlso: `NotificationCenter`
    /// - SeeAlso: `ActionProxy`
    ///
    public static let ActionDidFinishExecuting = Foundation.Notification.Name(rawValue: "Coherence.Connect.ActionDidFinishExecuting")

    ///
    /// Keys used by the notifications
    ///
    public struct Key {
        ///
        /// The `ActionProxy` for this notification.
        ///
        public static let ActionProxy = "ActionProxy"
    }
}

module OBSWS
  module Requests
    class Client
      include Logging
      include Mixin::TearDown
      include Mixin::OPCodes

      def initialize(**kwargs)
        @base_client = Base.new(**kwargs)
        logger.info("#{self} successfully identified with server")
      rescue Errno::ECONNREFUSED, WaitUtil::TimeoutError => e
        logger.error("#{e.class.name}: #{e.message}")
        raise OBSWSConnectionError.new(e.message)
      else
        @base_client.updater = ->(op_code, data) {
          logger.debug("response received: #{data}")
          @response = data if op_code == Mixin::OPCodes::REQUESTRESPONSE
        }
        @response = {requestId: 0}
      end

      def to_s
        self.class.name.split("::").last(2).join("::")
      end

      def run
        yield(self)
      ensure
        stop_driver
        WaitUtil.wait_for_condition(
          "driver to close",
          delay_sec: 0.01,
          timeout_sec: 1
        ) { @base_client.closed }
      end

      def call(req, data = nil)
        uuid = SecureRandom.uuid
        @base_client.req(uuid, req, data)
        WaitUtil.wait_for_condition(
          "reponse id to match request id",
          delay_sec: 0.001,
          timeout_sec: 3
        ) { @response[:requestId] == uuid }
        unless @response[:requestStatus][:result]
          raise OBSWSRequestError.new(@response[:requestType], @response[:requestStatus][:code], @response[:requestStatus][:comment])
        end
        @response[:responseData]
      rescue OBSWSRequestError => e
        logger.error(["#{e.class.name}: #{e.message}", *e.backtrace].join("\n"))
        raise
      rescue WaitUtil::TimeoutError => e
        logger.error(["#{e.class.name}: #{e.message}", *e.backtrace].join("\n"))
        raise OBSWSError.new([e.message, *e.backtrace].join("\n"))
      end

      def get_version
        resp = call(:GetVersion)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_stats
        resp = call(:GetStats)
        Mixin::Response.new(resp, resp.keys)
      end

      def broadcast_custom_event(data)
        call(:BroadcastCustomEvent, data)
      end

      def call_vendor_request(vendor_name, request_type, data = nil)
        payload = {vendorName: vendor_name, requestType: request_type}
        payload[:requestData] = data if data
        resp = call(:CallVendorRequest, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_hotkey_list
        resp = call(:GetHotkeyList)
        Mixin::Response.new(resp, resp.keys)
      end

      def trigger_hotkey_by_name(name)
        payload = {hotkeyName: name}
        call(:TriggerHotkeyByName, payload)
      end

      def trigger_hotkey_by_key_sequence(
        key_id,
        press_shift,
        press_ctrl,
        press_alt,
        press_cmd
      )
        payload = {
          keyId: key_id,
          keyModifiers: {
            shift: press_shift,
            control: press_ctrl,
            alt: press_alt,
            cmd: press_cmd
          }
        }
        call(:TriggerHotkeyByKeySequence, payload)
      end

      def sleep(sleep_millis = nil, sleep_frames = nil)
        payload = {sleepMillis: sleep_millis, sleepFrames: sleep_frames}
        call(:Sleep, payload)
      end

      def get_persistent_data(realm, slot_name)
        payload = {realm: realm, slotName: slot_name}
        resp = call(:GetPersistentData, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_persistent_data(realm, slot_name, slot_value)
        payload = {realm: realm, slotName: slot_name, slotValue: slot_value}
        call(:SetPersistentData, payload)
      end

      def get_scene_collection_list
        resp = call(:GetSceneCollectionList)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_current_scene_collection(name)
        payload = {sceneCollectionName: name}
        call(:SetCurrentSceneCollection, payload)
      end

      def create_scene_collection(name)
        payload = {sceneCollectionName: name}
        call(:CreateSceneCollection, payload)
      end

      def get_profile_list
        resp = call(:GetProfileList)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_current_profile(name)
        payload = {profileName: name}
        call(:SetCurrentProfile, payload)
      end

      def create_profile(name)
        payload = {profileName: name}
        call(:CreateProfile, payload)
      end

      def remove_profile(name)
        payload = {profileName: name}
        call(:RemoveProfile, payload)
      end

      def get_profile_parameter(category, name)
        payload = {parameterCategory: category, parameterName: name}
        resp = call(:GetProfileParameter, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_profile_parameter(category, name, value)
        payload = {
          parameterCategory: category,
          parameterName: name,
          parameterValue: value
        }
        call(:SetProfileParameter, payload)
      end

      def get_video_settings
        resp = call(:GetVideoSettings)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_video_settings(
        numerator,
        denominator,
        base_width,
        base_height,
        out_width,
        out_height
      )
        payload = {
          fpsNumerator: numerator,
          fpsDenominator: denominator,
          baseWidth: base_width,
          baseHeight: base_height,
          outputWidth: out_width,
          outputHeight: out_height
        }
        call(:SetVideoSettings, payload)
      end

      def get_stream_service_settings
        resp = call(:GetStreamServiceSettings)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_stream_service_settings(ss_type, ss_settings)
        payload = {
          streamServiceType: ss_type,
          streamServiceSettings: ss_settings
        }
        call(:SetStreamServiceSettings, payload)
      end

      def get_record_directory
        resp = call(:GetRecordDirectory)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_source_active(name)
        payload = {sourceName: name}
        resp = call(:GetSourceActive, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_source_screenshot(name, img_format, width, height, quality)
        payload = {
          sourceName: name,
          imageFormat: img_format,
          imageWidth: width,
          imageHeight: height,
          imageCompressionQuality: quality
        }
        resp = call(:GetSourceScreenshot, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def save_source_screenshot(
        name,
        img_format,
        file_path,
        width,
        height,
        quality
      )
        payload = {
          sourceName: name,
          imageFormat: img_format,
          imageFilePath: file_path,
          imageWidth: width,
          imageHeight: height,
          imageCompressionQuality: quality
        }
        resp = call(:SaveSourceScreenshot, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_scene_list
        resp = call(:GetSceneList)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_group_list
        resp = call(:GetGroupList)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_current_program_scene
        resp = call(:GetCurrentProgramScene)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_current_program_scene(name)
        payload = {sceneName: name}
        call(:SetCurrentProgramScene, payload)
      end

      def get_current_preview_scene
        resp = call(:GetCurrentPreviewScene)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_current_preview_scene(name)
        payload = {sceneName: name}
        call(:SetCurrentPreviewScene, payload)
      end

      def create_scene(name)
        payload = {sceneName: name}
        call(:CreateScene, payload)
      end

      def remove_scene(name)
        payload = {sceneName: name}
        call(:RemoveScene, payload)
      end

      def set_scene_name(old_name, new_name)
        payload = {sceneName: old_name, newSceneName: new_name}
        call(:SetSceneName, payload)
      end

      def get_scene_scene_transition_override(name)
        payload = {sceneName: name}
        resp = call(:GetSceneSceneTransitionOverride, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_scene_scene_transition_override(scene_name, tr_name, tr_duration)
        payload = {
          sceneName: scene_name,
          transitionName: tr_name,
          transitionDuration: tr_duration
        }
        call(:SetSceneSceneTransitionOverride, payload)
      end

      def get_input_list(kind = nil)
        payload = {inputKind: kind}
        resp = call(:GetInputList, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_input_kind_list(unversioned)
        payload = {unversioned: unversioned}
        resp = call(:GetInputKindList, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_special_inputs
        resp = call(:GetSpecialInputs)
        Mixin::Response.new(resp, resp.keys)
      end

      def create_input(
        scene_name,
        input_name,
        input_kind,
        input_settings,
        scene_item_enabled
      )
        payload = {
          sceneName: scene_name,
          inputName: input_name,
          inputKind: input_kind,
          inputSettings: input_settings,
          sceneItemEnabled: scene_item_enabled
        }
        resp = call(:CreateInput, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def remove_input(name)
        payload = {inputName: name}
        call(:RemoveInput, payload)
      end

      def set_input_name(old_name, new_name)
        payload = {inputName: old_name, newInputName: new_name}
        call(:SetInputName, payload)
      end

      def get_input_default_settings(kind)
        payload = {inputKind: kind}
        resp = call(:GetInputDefaultSettings, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_input_settings(name)
        payload = {inputName: name}
        resp = call(:GetInputSettings, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_input_settings(name, settings, overlay)
        payload = {inputName: name, inputSettings: settings, overlay: overlay}
        call(:SetInputSettings, payload)
      end

      def get_input_mute(name)
        payload = {inputName: name}
        resp = call(:GetInputMute, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_input_mute(name, muted)
        payload = {inputName: name, inputMuted: muted}
        call(:SetInputMute, payload)
      end

      def toggle_input_mute(name)
        payload = {inputName: name}
        resp = call(:ToggleInputMute, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_input_volume(name)
        payload = {inputName: name}
        resp = call(:GetInputVolume, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_input_volume(name, vol_mul = nil, vol_db = nil)
        payload = {
          inputName: name,
          inputVolumeMul: vol_mul,
          inputVolumeDb: vol_db
        }
        call(:SetInputVolume, payload)
      end

      def get_input_audio_balance(name)
        payload = {inputName: name}
        resp = call(:GetInputAudioBalance, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_input_audio_balance(name, balance)
        payload = {inputName: name, inputAudioBalance: balance}
        call(:SetInputAudioBalance, payload)
      end

      def get_input_audio_sync_offset(name)
        payload = {inputName: name}
        resp = call(:GetInputAudioSyncOffset, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_input_audio_sync_offset(name, offset)
        payload = {inputName: name, inputAudioSyncOffset: offset}
        call(:SetInputAudioSyncOffset, payload)
      end

      def get_input_audio_monitor_type(name)
        payload = {inputName: name}
        resp = call(:GetInputAudioMonitorType, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_input_audio_monitor_type(name, mon_type)
        payload = {inputName: name, monitorType: mon_type}
        call(:SetInputAudioMonitorType, payload)
      end

      def get_input_audio_tracks(name)
        payload = {inputName: name}
        resp = call(:GetInputAudioTracks, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_input_audio_tracks(name, track)
        payload = {inputName: name, inputAudioTracks: track}
        call(:SetInputAudioTracks, payload)
      end

      def get_input_properties_list_property_items(input_name, prop_name)
        payload = {inputName: input_name, propertyName: prop_name}
        resp = call(:GetInputPropertiesListPropertyItems, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def press_input_properties_button(input_name, prop_name)
        payload = {inputName: input_name, propertyName: prop_name}
        call(:PressInputPropertiesButton, payload)
      end

      def get_transition_kind_list
        resp = call(:GetTransitionKindList)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_scene_transition_list
        resp = call(:GetSceneTransitionList)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_current_scene_transition
        resp = call(:GetCurrentSceneTransition)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_current_scene_transition(name)
        payload = {transitionName: name}
        call(:SetCurrentSceneTransition, payload)
      end

      def set_current_scene_transition_duration(duration)
        payload = {transitionDuration: duration}
        call(:SetCurrentSceneTransitionDuration, payload)
      end

      def set_current_scene_transition_settings(settings, overlay = nil)
        payload = {transitionSettings: settings, overlay: overlay}
        call(:SetCurrentSceneTransitionSettings, payload)
      end

      def get_current_scene_transition_cursor
        resp = call(:GetCurrentSceneTransitionCursor)
        Mixin::Response.new(resp, resp.keys)
      end

      def trigger_studio_mode_transition
        call(:TriggerStudioModeTransition)
      end

      def set_t_bar_position(pos, release = nil)
        payload = {position: pos, release: release}
        call(:SetTBarPosition, payload)
      end

      def get_source_filter_list(name)
        payload = {sourceName: name}
        resp = call(:GetSourceFilterList, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_source_filter_default_settings(kind)
        payload = {filterKind: kind}
        resp = call(:GetSourceFilterDefaultSettings, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def create_source_filter(
        source_name,
        filter_name,
        filter_kind,
        filter_settings = nil
      )
        payload = {
          sourceName: source_name,
          filterName: filter_name,
          filterKind: filter_kind,
          filterSettings: filter_settings
        }
        call(:CreateSourceFilter, payload)
      end

      def remove_source_filter(source_name, filter_name)
        payload = {sourceName: source_name, filterName: filter_name}
        call(:RemoveSourceFilter, payload)
      end

      def set_source_filter_name(source_name, old_filter_name, new_filter_name)
        payload = {
          sourceName: source_name,
          filterName: old_filter_name,
          newFilterName: new_filter_name
        }
        call(:SetSourceFilterName, payload)
      end

      def get_source_filter(source_name, filter_name)
        payload = {sourceName: source_name, filterName: filter_name}
        resp = call(:GetSourceFilter, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_source_filter_index(source_name, filter_name, filter_index)
        payload = {
          sourceName: source_name,
          filterName: filter_name,
          filterIndex: filter_index
        }
        call(:SetSourceFilterIndex, payload)
      end

      def set_source_filter_settings(
        source_name,
        filter_name,
        settings,
        overlay = nil
      )
        payload = {
          sourceName: source_name,
          filterName: filter_name,
          filterSettings: settings,
          overlay: overlay
        }
        call(:SetSourceFilterSettings, payload)
      end

      def set_source_filter_enabled(source_name, filter_name, enabled)
        payload = {
          sourceName: source_name,
          filterName: filter_name,
          filterEnabled: enabled
        }
        call(:SetSourceFilterEnabled, payload)
      end

      def get_scene_item_list(name)
        payload = {sceneName: name}
        resp = call(:GetSceneItemList, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_group_scene_item_list(name)
        payload = {sceneName: name}
        resp = call(:GetGroupSceneItemList, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_scene_item_id(scene_name, source_name, offset = nil)
        payload = {
          sceneName: scene_name,
          sourceName: source_name,
          searchOffset: offset
        }
        resp = call(:GetSceneItemId, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def create_scene_item(scene_name, source_name, enabled = nil)
        payload = {
          sceneName: scene_name,
          sourceName: source_name,
          sceneItemEnabled: enabled
        }
        resp = call(:CreateSceneItem, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def remove_scene_item(scene_name, item_id)
        payload = {sceneName: scene_name, sceneItemId: item_id}
        call(:RemoveSceneItem, payload)
      end

      def duplicate_scene_item(scene_name, item_id, dest_scene_name = nil)
        payload = {
          sceneName: scene_name,
          sceneItemId: item_id,
          destinationSceneName: dest_scene_name
        }
        resp = call(:DuplicateSceneItem, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_scene_item_transform(scene_name, item_id)
        payload = {sceneName: scene_name, sceneItemId: item_id}
        resp = call(:GetSceneItemTransform, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_scene_item_transform(scene_name, item_id, transform)
        payload = {
          sceneName: scene_name,
          sceneItemId: item_id,
          sceneItemTransform: transform
        }
        call(:SetSceneItemTransform, payload)
      end

      def get_scene_item_enabled(scene_name, item_id)
        payload = {sceneName: scene_name, sceneItemId: item_id}
        resp = call(:GetSceneItemEnabled, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_scene_item_enabled(scene_name, item_id, enabled)
        payload = {
          sceneName: scene_name,
          sceneItemId: item_id,
          sceneItemEnabled: enabled
        }
        call(:SetSceneItemEnabled, payload)
      end

      def get_scene_item_locked(scene_name, item_id)
        payload = {sceneName: scene_name, sceneItemId: item_id}
        resp = call(:GetSceneItemLocked, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_scene_item_locked(scene_name, item_id, locked)
        payload = {
          sceneName: scene_name,
          sceneItemId: item_id,
          sceneItemLocked: locked
        }
        call(:SetSceneItemLocked, payload)
      end

      def get_scene_item_index(scene_name, item_id)
        payload = {sceneName: scene_name, sceneItemId: item_id}
        resp = call(:GetSceneItemIndex, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_scene_item_index(scene_name, item_id, item_index)
        payload = {
          sceneName: scene_name,
          sceneItemId: item_id,
          sceneItemIndex: item_index
        }
        call(:SetSceneItemIndex, payload)
      end

      def get_scene_item_blend_mode(scene_name, item_id)
        payload = {sceneName: scene_name, sceneItemId: item_id}
        resp = call(:GetSceneItemBlendMode, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_scene_item_blend_mode(scene_name, item_id, blend)
        payload = {
          sceneName: scene_name,
          sceneItemId: item_id,
          sceneItemBlendMode: blend
        }
        call(:SetSceneItemBlendMode, payload)
      end

      def get_virtual_cam_status
        resp = call(:GetVirtualCamStatus)
        Mixin::Response.new(resp, resp.keys)
      end

      def toggle_virtual_cam
        resp = call(:ToggleVirtualCam)
        Mixin::Response.new(resp, resp.keys)
      end

      def start_virtual_cam
        call(:StartVirtualCam)
      end

      def stop_virtual_cam
        call(:StopVirtualCam)
      end

      def get_replay_buffer_status
        resp = call(:GetReplayBufferStatus)
        Mixin::Response.new(resp, resp.keys)
      end

      def toggle_replay_buffer
        resp = call(:ToggleReplayBuffer)
        Mixin::Response.new(resp, resp.keys)
      end

      def start_replay_buffer
        call(:StartReplayBuffer)
      end

      def stop_replay_buffer
        call(:StopReplayBuffer)
      end

      def save_replay_buffer
        call(:SaveReplayBuffer)
      end

      def get_last_replay_buffer_replay
        resp = call(:GetLastReplayBufferReplay)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_output_list
        resp = call(:GetOutputList)
        Mixin::Response.new(resp, resp.keys)
      end

      def get_output_status(name)
        payload = {outputName: name}
        resp = call(:GetOutputStatus, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def toggle_output(name)
        payload = {outputName: name}
        resp = call(:ToggleOutput, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def start_output(name)
        payload = {outputName: name}
        call(:StartOutput, payload)
      end

      def stop_output(name)
        payload = {outputName: name}
        call(:StopOutput, payload)
      end

      def get_output_settings(name)
        payload = {outputName: name}
        resp = call(:GetOutputSettings, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_output_settings(name, settings)
        payload = {outputName: name, outputSettings: settings}
        call(:SetOutputSettings, payload)
      end

      def get_stream_status
        resp = call(:GetStreamStatus)
        Mixin::Response.new(resp, resp.keys)
      end

      def toggle_stream
        resp = call(:ToggleStream)
        Mixin::Response.new(resp, resp.keys)
      end

      def start_stream
        call(:StartStream)
      end

      def stop_stream
        call(:StopStream)
      end

      def send_stream_caption(caption)
        call(:SendStreamCaption)
      end

      def get_record_status
        resp = call(:GetRecordStatus)
        Mixin::Response.new(resp, resp.keys)
      end

      def toggle_record
        call(:ToggleRecord)
      end

      def start_record
        call(:StartRecord)
      end

      def stop_record
        resp = call(:StopRecord)
        Mixin::Response.new(resp, resp.keys)
      end

      def toggle_record_pause
        call(:ToggleRecordPause)
      end

      def pause_record
        call(:PauseRecord)
      end

      def resume_record
        call(:ResumeRecord)
      end

      def get_media_input_status(name)
        payload = {inputName: name}
        resp = call(:GetMediaInputStatus, payload)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_media_input_cursor(name, cursor)
        payload = {inputName: name, mediaCursor: cursor}
        call(:SetMediaInputCursor, payload)
      end

      def offset_media_input_cursor(name, offset)
        payload = {inputName: name, mediaCursorOffset: offset}
        call(:OffsetMediaInputCursor, payload)
      end

      def trigger_media_input_action(name, action)
        payload = {inputName: name, mediaAction: action}
        call(:TriggerMediaInputAction, payload)
      end

      def get_studio_mode_enabled
        resp = call(:GetStudioModeEnabled)
        Mixin::Response.new(resp, resp.keys)
      end

      def set_studio_mode_enabled(enabled)
        payload = {studioModeEnabled: enabled}
        call(:SetStudioModeEnabled, payload)
      end

      def open_input_properties_dialog(name)
        payload = {inputName: name}
        call(:OpenInputPropertiesDialog, payload)
      end

      def open_input_filters_dialog(name)
        payload = {inputName: name}
        call(:OpenInputFiltersDialog, payload)
      end

      def open_input_interact_dialog(name)
        payload = {inputName: name}
        call(:OpenInputInteractDialog, payload)
      end

      def get_monitor_list
        resp = call(:GetMonitorList)
        Mixin::Response.new(resp, resp.keys)
      end
    end
  end
end

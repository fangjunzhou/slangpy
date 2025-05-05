# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import pytest
import sys
import slangpy as spy
from pathlib import Path

sys.path.append(str(Path(__file__).parent))
import sglhelpers as helpers


@pytest.mark.parametrize("device_type", helpers.DEFAULT_DEVICE_TYPES)
def test_bindless_texture(device_type: spy.DeviceType):
    device = helpers.get_device(device_type)
    if not device.has_feature(spy.Feature.bindless):
        pytest.skip("Bindless not supported on this device.")
    if device_type == spy.DeviceType.vulkan:
        pytest.skip("Due to a slang bug bindless samplers are currently not supported on Vulkan.")

    module = device.load_module("test_bindless_texture.slang")

    print(module)
    # texture_infos = device.create_buffer()


    # helpers.dispatch_compute(
    #     device=device,
    #     path=Path(__file__).parent / "test_print.slang",
    #     entry_point="compute_main",
    #     thread_count=[1, 1, 1],
    # )


if __name__ == "__main__":
    pytest.main([__file__, "-vvvs"])

package br.app.vila.phonebook.service;

import br.app.vila.phonebook.model.Phone;
import br.app.vila.phonebook.repository.PhoneRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class PhoneServiceTest {
    @Mock
    private PhoneRepository phoneRepository;

    @InjectMocks
    private PhoneService phoneService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testFindAll() {
        List<Phone> mockPhones = Arrays.asList(
                new Phone(1L, "John Doe", "123456789"),
                new Phone(2L, "Jane Doe", "987654321")
        );
        when(phoneRepository.findAll()).thenReturn(mockPhones);

        List<Phone> phones = phoneService.findAll();

        assertNotNull(phones);
        assertEquals(2, phones.size());
        verify(phoneRepository, times(1)).findAll();
    }

    @Test
    void testFindById_ValidId() {
        Phone mockPhone = new Phone(1L, "John Doe", "123456789");
        when(phoneRepository.findById(1L)).thenReturn(Optional.of(mockPhone));

        Optional<Phone> phone = phoneService.findById(1L);

        assertTrue(phone.isPresent());
        assertEquals("John Doe", phone.get().getName());
        verify(phoneRepository, times(1)).findById(1L);
    }

    @Test
    void testFindById_InvalidId() {
        assertThrows(IllegalArgumentException.class, () -> phoneService.findById(null));
        assertThrows(IllegalArgumentException.class, () -> phoneService.findById(-1L));
        verify(phoneRepository, never()).findById(any());
    }

    @Test
    void testFindAllByName() {
        List<Phone> mockPhones = Arrays.asList(
                new Phone(1L, "John Doe", "123456789"),
                new Phone(2L, "Jane Doe", "987654321")
        );
        when(phoneRepository.findByNameContainingIgnoreCase("Doe")).thenReturn(mockPhones);

        List<Phone> phones = phoneService.findAllByName("Doe");

        assertNotNull(phones);
        assertEquals(2, phones.size());
        verify(phoneRepository, times(1)).findByNameContainingIgnoreCase("Doe");
    }

    @Test
    void testSave_ValidPhone() {
        Phone phone = new Phone(1L, "John Doe", "123456789");

        phoneService.save(phone);

        verify(phoneRepository, times(1)).save(phone);
    }

    @Test
    void testSave_InvalidPhone() {
        assertThrows(IllegalArgumentException.class, () -> phoneService.save(null));
        assertThrows(IllegalArgumentException.class, () -> phoneService.save(new Phone(1L, null, "123456789")));
        assertThrows(IllegalArgumentException.class, () -> phoneService.save(new Phone(1L, "John Doe", null)));
        assertThrows(IllegalArgumentException.class, () -> phoneService.save(new Phone(1L, "", "123456789")));
        assertThrows(IllegalArgumentException.class, () -> phoneService.save(new Phone(1L, "John Doe", "")));

        verify(phoneRepository, never()).save(any());
    }

    @Test
    void testDeleteById_ValidId() {
        phoneService.deleteById(1L);

        verify(phoneRepository, times(1)).deleteById(1L);
    }

    @Test
    void testDeleteById_InvalidId() {
        assertThrows(IllegalArgumentException.class, () -> phoneService.deleteById(null));
        assertThrows(IllegalArgumentException.class, () -> phoneService.deleteById(-1L));

        verify(phoneRepository, never()).deleteById(any());
    }
}
